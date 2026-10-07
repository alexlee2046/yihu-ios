// WeSpeaker feature extraction follows soniqo/speech-swift (Apache-2.0).
// CoreML model: aufklarer/WeSpeaker-ResNet34-LM-CoreML, revision
// b358f33f9e268a15aaf4aae0d4e747b82a8499e6 (MIT conversion;
// original pyannote/wespeaker-voxceleb-resnet34-LM, VoxCeleb CC BY 4.0).
import Accelerate
import AVFoundation
import CoreML
import CryptoKit
import Foundation

/// Local convenience filter, not authentication: a false positive is always possible.
enum CollieVoiceprint {
    static let threshold: Float = 0.70
    static let minimumVoicedSamples = 16_000 // 1 s at 16 kHz; shorter input needs manual confirmation.
    static let enrollmentMinimumVoicedSamples = 32_000 // registration needs longer, cleaner phrases.
    static let enrollmentPhraseCount = 6 // three quiet + three in a different everyday environment
    static let prompts = [
        "早上好，今天我想用一呼整理任务，please help me plan my day。",
        "我正在录制自己的声音，the quick brown fox jumps over the lazy dog。",
        "请记录这个想法，明天我们再讨论 next steps and priorities。",
        "现在换一个地方，我会继续用正常语速说话。",
        "这是另一处日常环境里的声纹录音。",
        "无论附近是否有声音，请只识别我的说话声。"
    ]
    fileprivate static let modelHashes = [
        "weights/weight.bin": "6dba18a57a81b1e872802ca4def29541bb7900ccff430d9b2040092cadd7d688",
        "model.mil": "e1f3d6188067607d5e91aa5004aeffb35c9f367b85628eff2e87c59ac5c379f2",
        "metadata.json": "885d8e956a649e79a099e35acf367021c86091e321ebef26e2ad9d89c3ff757f",
        "coremldata.bin": "bf152705e26efe04fac84bc332c395443d4b5c4cc1b2891ffd5e274e53b365b2",
        "analytics/coremldata.bin": "f22f984e4419ebc6682dbe6a2ce990c876144eb6e43e9e4843b92917bdcd5ba7"
    ]
    static let enabledKey = "collie.voiceprint.enabled"
    static let captureModeChangedNotice = "近场收音设置已变，建议重新录制声纹"

    struct Profile: Codable {
        let version: Int
        let embeddings: [[Float]]
        var camEmbeddings: [[Float]]? = nil
        var environments: [String]? = nil
        var nearFieldCaptureEnabled: Bool? = nil
    }

    enum Decision: Equatable {
        case bypass, match(Float), mismatch(Float), unavailable
    }

    static func decide(
        enabled: Bool,
        profileCaptureModeMatches: Bool = true,
        reference: [[Float]]?, candidate: [Float]?, voicedSamples: Int
    ) -> Decision {
        guard enabled else { return .bypass }
        guard profileCaptureModeMatches else { return .unavailable }
        guard voicedSamples >= minimumVoicedSamples else { return .unavailable }
        guard let reference, (reference.count == 3 || reference.count == enrollmentPhraseCount),
              let candidate, candidate.count == 256,
              candidate.allSatisfy(\.isFinite) else { return .unavailable }
        guard let mean = meanEmbedding(reference) else { return .unavailable }
        let score = cosine(mean, candidate)
        guard score.isFinite else { return .unavailable }
        return score >= threshold ? .match(score) : .mismatch(score)
    }

    /// Each sentence contributes equally regardless of recording loudness or vector magnitude.
    static func meanEmbedding(_ vectors: [[Float]]) -> [Float]? {
        guard vectors.count == 3 || vectors.count == enrollmentPhraseCount,
              let dimension = vectors.first?.count, (128...1024).contains(dimension) else { return nil }
        var sum = [Float](repeating: 0, count: dimension)
        for vector in vectors {
            guard vector.count == dimension, vector.allSatisfy(\.isFinite) else { return nil }
            let length = sqrt(vector.reduce(Float(0)) { $0 + $1 * $1 })
            guard length.isFinite, length > 0 else { return nil }
            for i in 0..<dimension { sum[i] += vector[i] / length }
        }
        let length = sqrt(sum.reduce(Float(0)) { $0 + $1 * $1 })
        guard length.isFinite, length > 0 else { return nil }
        return sum.map { $0 / length }
    }

    // Provisional enrollment floors, not a biometric identity guarantee. Fixture
    // different-speaker scores: WeSpeaker 0.111, CAM++ 0.198; cross-environment
    // 0.45 leaves at least 0.25 margin above both while allowing noisier speech.
    // Same-speaker fixtures were 0.905 / 0.930. Calibrate on real people/device.
    static let enrollmentMinimumSimilarity: Float = 0.55
    static let enrollmentCrossEnvironmentMinimumSimilarity: Float = 0.45

    static func enrollmentIsConsistent(_ vectors: [[Float]]) -> Bool {
        guard !vectors.isEmpty, vectors.count <= enrollmentPhraseCount,
              let dimension = vectors.first?.count,
              vectors.allSatisfy({ $0.count == dimension }) else { return false }
        for i in vectors.indices {
            for j in vectors.indices where j > i {
                // A lower, but still discriminative, floor allows everyday background noise.
                let crossEnvironment = vectors.count > 3 && (i < 3) != (j < 3)
                let floor = crossEnvironment ? enrollmentCrossEnvironmentMinimumSimilarity : enrollmentMinimumSimilarity
                guard cosine(vectors[i], vectors[j]) >= floor else { return false }
            }
        }
        return true
    }

    static func cosine(_ a: [Float], _ b: [Float]) -> Float {
        guard !a.isEmpty, a.count == b.count else { return .nan }
        var dot: Float = 0, aa: Float = 0, bb: Float = 0
        for i in a.indices { dot += a[i] * b[i]; aa += a[i] * a[i]; bb += b[i] * b[i] }
        guard aa > 0, bb > 0 else { return .nan }
        return dot / sqrt(aa * bb)
    }

    /// Energy-based duration estimate, not speech recognition; bypass short/quiet clips.
    static func voicedRange(_ samples: [Float]) -> (range: Range<Int>, count: Int) {
        let block = 320
        guard samples.count >= block else { return (0..<samples.count, 0) }
        var energies: [Float] = []
        for start in stride(from: 0, through: samples.count - block, by: block) {
            var sum: Float = 0
            for index in start..<(start + block) { sum += samples[index] * samples[index] }
            energies.append(sqrt(sum / Float(block)))
        }
        let gate = max(0.003, (energies.max() ?? 0) * 0.10)
        let active = energies.indices.filter { energies[$0] >= gate }
        guard let first = active.first, let last = active.last else { return (0..<samples.count, 0) }
        return ((first * block)..<min(samples.count, (last + 1) * block), active.count * block)
    }

    enum VoiceprintError: Error { case missingModel, invalidModel, invalidFeatures, emptyEmbedding, invalidProfile, shortRecording, legacyRemovalFailed }

    static func embedding(_ audio: [Float], segment: (range: Range<Int>, count: Int)? = nil) async throws -> (vector: [Float], voicedSamples: Int) {
        let segment = segment ?? voicedRange(audio)
        guard segment.count >= minimumVoicedSamples else { throw VoiceprintError.shortRecording }
        try Task.checkCancellation()
        let vector = try await VoiceprintInference.shared.embedding(audio, range: segment.range)
        return (vector, segment.count)
    }
}

/// Serializes Core ML calls, checks the pinned bundle once, and retains the prepared extractor.
private actor VoiceprintInference {
    static let shared = VoiceprintInference()
    private var model: MLModel?
    private var extractor: VoiceprintMelExtractor?

    private func loadedModel() throws -> MLModel {
        if let model { return model }
        guard let url = Bundle.main.url(forResource: "WeSpeaker", withExtension: "mlmodelc") else {
            throw CollieVoiceprint.VoiceprintError.missingModel
        }
        for (path, expected) in CollieVoiceprint.modelHashes {
            try Task.checkCancellation()
            guard let data = try? Data(contentsOf: url.appendingPathComponent(path), options: .mappedIfSafe),
                  SHA256.hash(data: data).map({ String(format: "%02x", $0) }).joined() == expected else {
                throw CollieVoiceprint.VoiceprintError.invalidModel
            }
        }
        try Task.checkCancellation()
        let configuration = MLModelConfiguration()
        #if targetEnvironment(simulator)
        configuration.computeUnits = .cpuOnly // Simulator GPU path returns zero vectors.
        #else
        configuration.computeUnits = .cpuAndNeuralEngine
        #endif
        let loaded = try MLModel(contentsOf: url, configuration: configuration)
        try Task.checkCancellation()
        model = loaded
        return loaded
    }

    func embedding(_ audio: [Float], range: Range<Int>) throws -> [Float] {
        try Task.checkCancellation()
        let model = try loadedModel()
        try Task.checkCancellation()
        if extractor == nil { extractor = VoiceprintMelExtractor() }
        let features = extractor!.extract(Array(audio[range]))
        try Task.checkCancellation()
        guard features.values.contains(where: { $0.isFinite && abs($0) > 0.0001 }) else {
            throw CollieVoiceprint.VoiceprintError.invalidFeatures
        }
        let lengths = [20, 50, 100, 200, 300, 500, 750, 1000, 1500, 2000]
        let length = lengths.first(where: { $0 >= features.frames }) ?? 2000
        let tensor = try MLMultiArray(shape: [1, NSNumber(value: length), 80], dataType: .float16)
        let pointer = tensor.dataPointer.assumingMemoryBound(to: Float16.self)
        for i in 0..<min(features.values.count, length * 80) { pointer[i] = Float16(features.values[i]) }
        // Model has enumerated frame lengths; zero-pad (or truncate) like speech-swift.
        for i in min(features.values.count, length * 80)..<(length * 80) { pointer[i] = 0 }
        let input = try MLDictionaryFeatureProvider(dictionary: ["mel": tensor])
        try Task.checkCancellation()
        let output = try model.prediction(from: input)
        try Task.checkCancellation()
        guard let result = output.featureValue(for: "embedding")?.multiArrayValue, result.count == 256 else {
            throw CollieVoiceprint.VoiceprintError.invalidModel
        }
        let vector = (0..<256).map { result[$0].floatValue }
        guard vector.allSatisfy(\.isFinite), CollieVoiceprint.cosine(vector, vector).isFinite else {
            throw CollieVoiceprint.VoiceprintError.emptyEmbedding
        }
        return vector
    }
}

/// Main-actor cache: never turn an enabled filter off merely because a file is unavailable.
@MainActor
final class CollieVoiceprintStore {
    static let shared = CollieVoiceprintStore()
    private let directory: URL
    private let defaults: UserDefaults
    private let removeFile: (URL) throws -> Void
    private var enabled: Bool
    private var loaded = false
    private var cachedProfile: [[Float]]?
    private var cachedCAM: [[Float]]?
    private var cachedNearFieldCaptureEnabled: Bool?
    private let fileName = "voiceprint-v2.json"
    private let legacyFileName = "voiceprint-v1.json"

    init(directory: URL? = nil, defaults: UserDefaults = .standard,
         removeFile: @escaping (URL) throws -> Void = { try FileManager.default.removeItem(at: $0) }) {
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory,
                                                                 in: .userDomainMask)[0]
            .appendingPathComponent("CollieVoiceprint", isDirectory: true)
        self.defaults = defaults
        self.removeFile = removeFile
        enabled = defaults.bool(forKey: CollieVoiceprint.enabledKey)
    }

    var isEnabled: Bool {
        get { enabled }
        set {
            guard enabled != newValue else { return }
            enabled = newValue
            defaults.set(newValue, forKey: CollieVoiceprint.enabledKey)
        }
    }

    func load() -> [[Float]]? {
        if loaded { return cachedProfile }
        loaded = true
        let current = directory.appendingPathComponent(fileName)
        let hasCurrent = FileManager.default.fileExists(atPath: current.path)
        let url = hasCurrent ? current : directory.appendingPathComponent(legacyFileName)
        guard let data = try? Data(contentsOf: url),
              let profile = try? JSONDecoder().decode(CollieVoiceprint.Profile.self, from: data),
              (hasCurrent ? profile.version == 2 && profile.embeddings.count == CollieVoiceprint.enrollmentPhraseCount
                          : profile.version == 1 && profile.embeddings.count == 3),
              profile.embeddings.allSatisfy({ $0.count == 256 && $0.allSatisfy(\.isFinite) && CollieVoiceprint.cosine($0, $0).isFinite }),
              CollieVoiceprint.enrollmentIsConsistent(profile.embeddings),
              (!hasCurrent || profile.camEmbeddings == nil ||
               (profile.camEmbeddings?.count == CollieVoiceprint.enrollmentPhraseCount &&
                profile.camEmbeddings?.allSatisfy({ $0.count == 192 && $0.allSatisfy(\.isFinite) }) == true &&
                profile.camEmbeddings.map(CollieVoiceprint.enrollmentIsConsistent) == true)),
              (!hasCurrent || profile.environments == nil ||
               profile.environments == ["安静", "安静", "安静", "日常", "日常", "日常"]) else { return nil }
        cachedCAM = profile.camEmbeddings
        cachedNearFieldCaptureEnabled = profile.nearFieldCaptureEnabled ?? false
        cachedProfile = profile.embeddings
        return cachedProfile
    }

    func reload() -> [[Float]]? {
        loaded = false
        cachedCAM = nil
        cachedNearFieldCaptureEnabled = nil
        cachedProfile = nil
        return load()
    }

    func camEmbeddings() -> [[Float]]? {
        _ = load()
        return cachedCAM
    }

    func captureModeMatches(currentNearFieldEnabled: Bool) -> Bool {
        guard load() != nil else { return false }
        return (cachedNearFieldCaptureEnabled ?? false) == currentNearFieldEnabled
    }

    func save(_ embeddings: [[Float]], camEmbeddings: [[Float]]? = nil, nearFieldCaptureEnabled: Bool = false) throws {
        guard embeddings.count == CollieVoiceprint.enrollmentPhraseCount,
              embeddings.allSatisfy({ $0.count == 256 && $0.allSatisfy(\.isFinite) && CollieVoiceprint.cosine($0, $0).isFinite }),
              CollieVoiceprint.enrollmentIsConsistent(embeddings),
              camEmbeddings == nil ||
                  (camEmbeddings?.count == CollieVoiceprint.enrollmentPhraseCount &&
                   camEmbeddings?.allSatisfy({ $0.count == 192 && $0.allSatisfy(\.isFinite) }) == true &&
                   camEmbeddings.map(CollieVoiceprint.enrollmentIsConsistent) == true)
        else { throw CollieVoiceprint.VoiceprintError.invalidProfile }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
                                                attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var folder = directory
        try folder.setResourceValues(values)
        var file = directory.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(CollieVoiceprint.Profile(
            version: 2, embeddings: embeddings, camEmbeddings: camEmbeddings,
            environments: ["安静", "安静", "安静", "日常", "日常", "日常"],
            nearFieldCaptureEnabled: nearFieldCaptureEnabled))
        try data.write(to: file, options: [.atomic, .completeFileProtectionUnlessOpen])
        try file.setResourceValues(values)
        cachedCAM = camEmbeddings
        cachedNearFieldCaptureEnabled = nearFieldCaptureEnabled
        cachedProfile = embeddings
        loaded = true
        // Only after the new profile is durable may the superseded private data go.
        let legacy = directory.appendingPathComponent(legacyFileName)
        if FileManager.default.fileExists(atPath: legacy.path) {
            do { try removeFile(legacy) }
            catch { throw CollieVoiceprint.VoiceprintError.legacyRemovalFailed }
        }
    }

    func delete() throws {
        // Delete legacy first: a partial failure must never silently resurrect an old profile.
        for name in [legacyFileName, fileName] {
            let file = directory.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: file.path) { try removeFile(file) }
        }
        cachedCAM = nil
        cachedNearFieldCaptureEnabled = nil
        cachedProfile = nil
        loaded = true
        isEnabled = false
    }
}

@MainActor
protocol CollieVoiceprintChecking {
    var isEnabled: Bool { get }
    func decision(for samples: [Float], segment: (range: Range<Int>, count: Int)) async -> CollieVoiceprint.Decision
}

@MainActor
struct CollieLocalVoiceprintChecker: CollieVoiceprintChecking {
    let store: CollieVoiceprintStore
    init(store: CollieVoiceprintStore = .shared) { self.store = store }
    var isEnabled: Bool { store.isEnabled }

    func decision(for samples: [Float], segment: (range: Range<Int>, count: Int)) async -> CollieVoiceprint.Decision {
        guard store.captureModeMatches(currentNearFieldEnabled: CollieAudioCapturePreferences.nearFieldCaptureEnabled()),
              let reference = store.load() else { return .unavailable }
        let result = try? await CollieVoiceprint.embedding(samples, segment: segment)
        guard !Task.isCancelled else { return .unavailable }
        return CollieVoiceprint.decide(enabled: true, profileCaptureModeMatches: true, reference: reference,
                                      candidate: result?.vector, voicedSamples: segment.count)
    }
}

/// 16 kHz, 80-bin log-mel + temporal mean normalization, aligned with speech-swift.
private final class VoiceprintMelExtractor {
    private let nFFT = 400, hop = 160, paddedFFT = 512, melCount = 80
    private let fft = vDSP_create_fftsetup(9, FFTRadix(kFFTRadix2))!
    private let window: [Float]
    private let filters: [Float]

    init() {
        window = (0..<400).map { 0.54 - 0.46 * cos(2 * .pi * Float($0) / 399) }
        func mel(_ h: Float) -> Float { 2595 * log10(1 + h / 700) }
        func hz(_ m: Float) -> Float { 700 * (pow(10, m / 2595) - 1) }
        let points = (0..<82).map { hz(mel(20) + Float($0) * (mel(8000) - mel(20)) / 81) }
        var bank = [Float](repeating: 0, count: 80 * 257)
        for m in 0..<80 {
            for k in 0..<257 {
                let frequency = Float(k) * 16000 / 512
                let left = (frequency - points[m]) / (points[m + 1] - points[m])
                let right = (points[m + 2] - frequency) / (points[m + 2] - points[m + 1])
                bank[m * 257 + k] = max(0, min(left, right)) * 2 / (points[m + 2] - points[m])
            }
        }
        filters = bank
    }

    deinit { vDSP_destroy_fftsetup(fft) }

    func extract(_ audio: [Float]) -> (values: [Float], frames: Int) {
        var emphasized = audio
        if audio.count > 1 {
            for i in 1..<audio.count { emphasized[i] = audio[i] - 0.97 * audio[i - 1] }
        }
        let pad = nFFT / 2
        var samples = [Float](repeating: 0, count: audio.count + 2 * pad)
        for i in 0..<pad {
            samples[i] = emphasized[min(pad - i, audio.count - 1)]
            samples[pad + audio.count + i] = emphasized[max(0, audio.count - 2 - i)]
        }
        for i in audio.indices { samples[pad + i] = emphasized[i] }
        let frames = (samples.count - nFFT) / hop + 1
        var result = [Float](repeating: 0, count: frames * melCount)
        for frame in 0..<frames {
            var real = [Float](repeating: 0, count: 256)
            var imag = [Float](repeating: 0, count: 256)
            let offset = frame * hop
            for j in 0..<256 {
                real[j] = 2 * j < nFFT ? samples[offset + 2 * j] * window[2 * j] : 0
                imag[j] = 2 * j + 1 < nFFT ? samples[offset + 2 * j + 1] * window[2 * j + 1] : 0
            }
            real.withUnsafeMutableBufferPointer { r in
                imag.withUnsafeMutableBufferPointer { i in
                    var split = DSPSplitComplex(realp: r.baseAddress!, imagp: i.baseAddress!)
                    vDSP_fft_zrip(fft, &split, 1, 9, FFTDirection(kFFTDirection_Forward))
                }
            }
            var power = [Float](repeating: 0, count: 257)
            power[0] = real[0] * real[0]
            power[256] = imag[0] * imag[0]
            for k in 1..<256 { power[k] = real[k] * real[k] + imag[k] * imag[k] }
            for m in 0..<melCount {
                var energy: Float = 0
                for k in 0..<257 { energy += power[k] * filters[m * 257 + k] }
                result[frame * melCount + m] = log(max(energy, 1e-10))
            }
        }
        for m in 0..<melCount {
            var mean: Float = 0
            for frame in 0..<frames { mean += result[frame * melCount + m] }
            mean /= Float(frames)
            for frame in 0..<frames { result[frame * melCount + m] -= mean }
        }
        return (result, frames)
    }
}
