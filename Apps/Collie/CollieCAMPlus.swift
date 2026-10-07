import Accelerate
import CoreML
import CryptoKit
import Foundation

/// Local, experimental second speaker model. WeSpeaker remains the fill gate until device calibration.
actor CollieCAMPlus {
    static let shared = CollieCAMPlus()
    private var model: MLModel?
    private var fbank: CollieCAMPlusFbank?

    enum CAMError: Error { case modelUnavailable, invalidModel, insufficientAudio, invalidEmbedding }

    // Xcode's Core ML compiler preserves the model graph and weights on both
    // platforms/configurations. coremldata.bin may permute its three metadata
    // key-value records (all six exact hashes pinned here; Debug and Release
    // observed different orders). metadata.json is hashed with sorted JSON keys.
    private static let compiledHashes: [(path: String, sha256: Set<String>)] = [
        ("weights/weight.bin", ["3e5bafbc3d3faa94aff8c72afd22ffae97ce31d87ce70c000585e055cd776c18"]),
        ("model.mil", ["1765f71607da7b1632b3126e540aa795badd2c5aa1c57a40bf5c28978ae0a0ba"]),
        ("coremldata.bin", [
            "1ed43d070c326c585f5651ecc253e2c307e790e32a140c204106e67443546e83",
            "d47a6127a1708a0fcf6009ef50291efdb7d7f3600182058a64c5b0a3e21eb316",
            "42d9eaea4f873697eb827a33f61414c4b2d0c146e02492e506a0ae98a96a8a64",
            "a54a8fb84590fefd79d6050f7de3ede4ef95e7cc1dd91160c160a9da05203eb5",
            "11cda48a7ae97186b7322080569db4890e6816d2a9dae8a46721d830d8ed3be4",
            "37a493a5167e4f87e5b9a70cf26d3167f08aee2b2da57607230049786589d970",
        ]),
        ("analytics/coremldata.bin", ["a861fff85ecd2dfe0edfd059da707e112e7f111b6d9331832987a24b1715ae0d"]),
        ("metadata.json", ["3b59fb6b2414061ad67c93dac41bb4174e987090424846aa98dac6f7448d950f"]),
    ]

    static func verifyCompiledModel(at url: URL) -> Bool {
        for (path, allowedHashes) in compiledHashes {
            guard let original = try? Data(contentsOf: url.appendingPathComponent(path), options: .mappedIfSafe) else {
                return false
            }
            let data: Data
            if path == "metadata.json" {
                guard let json = try? JSONSerialization.jsonObject(with: original),
                      let sorted = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys]) else {
                    return false
                }
                data = sorted
            } else { data = original }
            let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            guard allowedHashes.contains(digest) else { return false }
        }
        return true
    }

    func embedding(samples: [Float], segment: (range: Range<Int>, count: Int)? = nil) throws -> [Float] {
        try Task.checkCancellation()
        let voiced = segment ?? CollieVoiceprint.voicedRange(samples)
        guard voiced.count >= CollieVoiceprint.minimumVoicedSamples else { throw CAMError.insufficientAudio }
        let extractor = fbank ?? CollieCAMPlusFbank()
        fbank = extractor
        let (frames, features) = extractor.extract(samples: samples, range: voiced.range)
        guard frames >= 98 else { throw CAMError.insufficientAudio }
        let input = try MLMultiArray(shape: [1, NSNumber(value: frames), 80], dataType: .float32)
        features.withUnsafeBufferPointer { values in
            input.dataPointer.copyMemory(from: values.baseAddress!, byteCount: features.count * MemoryLayout<Float>.size)
        }
        let output = try loadedModel().prediction(from: MLDictionaryFeatureProvider(dictionary: ["fbank": input]))
        guard let embedding = output.featureValue(for: "embedding")?.multiArrayValue,
              embedding.count == 192 else { throw CAMError.invalidEmbedding }
        try Task.checkCancellation()
        let vector = (0..<192).map { embedding[$0].floatValue }
        let magnitude = sqrt(vector.reduce(Float(0)) { $0 + $1 * $1 })
        guard vector.allSatisfy(\.isFinite), magnitude.isFinite, magnitude > 1e-8 else {
            throw CAMError.invalidEmbedding
        }
        return vector.map { $0 / magnitude }
    }

    private func loadedModel() throws -> MLModel {
        if let model { return model }
        guard let url = Bundle.main.url(forResource: "CAMPlus", withExtension: "mlmodelc") else {
            throw CAMError.modelUnavailable
        }
        try Task.checkCancellation()
        guard Self.verifyCompiledModel(at: url) else { throw CAMError.invalidModel }
        try Task.checkCancellation()
        let config = MLModelConfiguration()
        #if targetEnvironment(simulator)
        config.computeUnits = .cpuOnly
        #else
        config.computeUnits = .cpuAndNeuralEngine
        #endif
        let loaded = try MLModel(contentsOf: url, configuration: config)
        model = loaded
        return loaded
    }
}

/// Kaldi-style fbank used by official 3D-Speaker CAM++: 16kHz, 25ms/10ms,
/// 80 mel bins, 512-point power FFT, Povey window, 0.97 preemphasis, no dither,
/// snip_edges, remove DC offset, HTK mel 20–8000Hz, utterance mean subtraction.
/// Reference: speakerlab/process/processor.py + torchaudio.compliance.kaldi.fbank.
final class CollieCAMPlusFbank {
    private let window: [Float] = (0..<400).map { pow(0.5 - 0.5 * cos(2 * .pi * Float($0) / 399), 0.85) }
    private let weights: [Float]
    private let fft = vDSP_create_fftsetup(9, FFTRadix(kFFTRadix2))!

    init() {
        let mel: (Float) -> Float = { 1127 * log1p($0 / 700) }
        let minMel = mel(20), maxMel = mel(8000)
        let step = (maxMel - minMel) / 81
        var weights = [Float](repeating: 0, count: 80 * 257)
        for bin in 0..<80 {
            let left = minMel + Float(bin) * step
            let right = left + 2 * step
            for frequencyBin in 0..<256 { // Kaldi leaves the Nyquist bin unused.
                let value = mel(Float(frequencyBin) * 16000 / 512)
                weights[bin * 257 + frequencyBin] = max(0, min((value - left) / step, (right - value) / step))
            }
        }
        self.weights = weights
    }

    deinit { vDSP_destroy_fftsetup(fft) }

    func extract(samples: [Float], range: Range<Int>) -> (frames: Int, values: [Float]) {
        guard range.count >= 400, range.lowerBound >= 0, range.upperBound <= samples.count else { return (0, []) }
        let frames = 1 + (range.count - 400) / 160
        var features = [Float](repeating: 0, count: frames * 80)
        var frame = [Float](repeating: 0, count: 512)
        var power = [Float](repeating: 0, count: 257)
        var real = [Float](repeating: 0, count: 256)
        var imaginary = [Float](repeating: 0, count: 256)
        for index in 0..<frames {
            let start = range.lowerBound + index * 160
            var mean: Float = 0
            for offset in 0..<400 { mean += samples[start + offset] }
            mean /= 400
            let first = samples[start] - mean
            frame[0] = first * 0.03 * window[0]
            for offset in 1..<400 {
                let current = samples[start + offset] - mean
                let previous = samples[start + offset - 1] - mean
                frame[offset] = (current - 0.97 * previous) * window[offset]
            }
            for offset in 400..<512 { frame[offset] = 0 }
            for bin in 0..<256 {
                real[bin] = frame[2 * bin]
                imaginary[bin] = frame[2 * bin + 1]
            }
            real.withUnsafeMutableBufferPointer { realBuffer in
                imaginary.withUnsafeMutableBufferPointer { imaginaryBuffer in
                    var split = DSPSplitComplex(realp: realBuffer.baseAddress!, imagp: imaginaryBuffer.baseAddress!)
                    vDSP_fft_zrip(fft, &split, 1, 9, FFTDirection(kFFTDirection_Forward))
                }
            }
            // Accelerate's packed real FFT has twice the conventional rFFT amplitude.
            power[0] = 0.25 * real[0] * real[0]
            for bin in 1..<256 {
                power[bin] = 0.25 * (real[bin] * real[bin] + imaginary[bin] * imaginary[bin])
            }
            power[256] = 0
            for melBin in 0..<80 {
                var sum: Float = 0
                let offset = melBin * 257
                for bin in 0..<256 { sum += power[bin] * weights[offset + bin] }
                features[index * 80 + melBin] = log(max(Float.ulpOfOne, sum))
            }
        }
        for bin in 0..<80 {
            var total: Float = 0
            for index in 0..<frames { total += features[index * 80 + bin] }
            let average = total / Float(frames)
            for index in 0..<frames { features[index * 80 + bin] -= average }
        }
        return (frames, features)
    }
}
