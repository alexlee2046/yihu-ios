// Derived from soniqo/speech-swift ca4daaf9be7cccf230f691e443cd80b7a0bd8d97 (Apache-2.0).
#if canImport(CoreML)
import CoreML
import Foundation

/// CoreML audio encoder for Qwen3-ASR.
///
/// Runs the audio encoder on Neural Engine via CoreML instead of GPU via MLX.
/// Produces audio embeddings that feed into the MLX text decoder. This enables
/// lower power consumption on macOS and is a step toward full iOS deployment.
///
/// The encoder uses a single fixed 30 s mel shape ``[1, 128, 3000]`` and
/// applies upstream's chunked block-attention (100-frame chunks → 13 tokens
/// each, 8-chunk attention windows). Mel input is zero-padded to 3000 frames
/// and the real length is signaled via a separate ``mel_length`` input so
/// the in-graph block-attention bias can mask out the padded frames; the
/// model returns the matching real audio-token count via ``output_length``.
public class CoreMLASREncoder {
    private let model: MLModel
    /// Fixed mel length the chunked-attention encoder is exported with.
    /// 3000 mel frames = 30 s @ 100 Hz hop, matching upstream training.
    public static let paddedMelLength: Int = 3000
    /// Max audio tokens out of the padded encoder (3000 mel / 8 conv stride ≈
    /// 30 chunks × 13 tokens). The model writes the real count to ``output_length``.
    public static let paddedAudioTokens: Int = 390

    public static let defaultModelId = "aufklarer/Qwen3-ASR-CoreML"

    /// Embeddings + the real, un-padded audio-token count (from the model's
    /// ``output_length`` output). Callers should iterate only the first
    /// ``outputLength`` tokens of ``embeddings``.
    public struct EncodedAudio {
        public let embeddings: MLMultiArray
        public let outputLength: Int
    }

    public init(model: MLModel) {
        self.model = model
    }

    /// Load encoder from a directory containing `encoder.mlmodelc`.
    public static func load(
        from directory: URL,
        computeUnits: MLComputeUnits = .all
    ) throws -> CoreMLASREncoder {
        let modelURL = directory.appendingPathComponent("encoder.mlmodelc", isDirectory: true)
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            throw AudioModelError.modelLoadFailed(
                modelId: "encoder",
                reason: "CoreML encoder not found at \(modelURL.path)")
        }

        let config = MLModelConfiguration()
        config.computeUnits = computeUnits
        let model = try MLModel(contentsOf: modelURL, configuration: config)
        return CoreMLASREncoder(model: model)
    }

    /// Warm up the encoder with a short dummy input to trigger CoreML compilation.
    public func warmUp() throws {
        // Use a small fake length so warmup doesn't depend on a real clip.
        _ = try encodeRaw(melData: [Float](repeating: 0, count: 128 * 100),
                          melBins: 128, realFrames: 100)
    }

    // MARK: - MLX-free encoding (for iOS background / pure CoreML path)

    /// Encode mel spectrogram to audio embeddings without any MLXArray dependency.
    ///
    /// Accepts raw `[Float]` mel data in `[melBins, timeFrames]` layout (the same
    /// layout produced by `WhisperFeatureExtractor.extractFeaturesRaw`).
    /// Returns the encoder output as `MLMultiArray` directly, avoiding the
    /// Metal GPU eval that `MLXArray` would trigger.
    ///
    /// - Parameters:
    ///   - melData: Flat float array in row-major `[melBins, timeFrames]` order
    ///   - melBins: Number of mel frequency bins (typically 128)
    ///   - timeFrames: Number of time frames
    /// - Returns: Audio embeddings as `MLMultiArray` with shape `[1, T/8, 1024]`
    public func encode(melData: [Float], melBins: Int, timeFrames: Int) throws -> EncodedAudio {
        return try encodeRaw(melData: melData, melBins: melBins, realFrames: timeFrames)
    }

    /// Convenience: encode a `MelFeatures` struct directly.
    public func encode(melFeatures: MelFeatures) throws -> EncodedAudio {
        return try encodeRaw(melData: melFeatures.data,
                             melBins: melFeatures.melBins,
                             realFrames: melFeatures.timeFrames)
    }

    /// Clamp a model-reported audio-token count to what the embeddings
    /// tensor can actually supply.
    ///
    /// ``output_length`` is computed in-graph. A re-export whose length
    /// formula outran its own output tensor would otherwise hand callers an
    /// index range that reads past the buffer — the same class of fault as
    /// reading the Float16 embeddings as Float32, arriving by a different
    /// route. ``internal`` so it is unit-testable without the model.
    static func clampOutputLength(_ reported: Int, embeddingShape shape: [Int]) -> Int {
        let availableTokens = shape.count >= 2 ? shape[shape.count - 2] : 0
        return min(max(0, reported), max(0, availableTokens))
    }

    /// Shared core: zero-pads ``melData`` to the fixed ``paddedMelLength``,
    /// runs the two-input/two-output graph, and returns the model's reported
    /// ``output_length`` alongside the full padded embeddings.
    private func encodeRaw(
        melData: [Float], melBins: Int, realFrames: Int
    ) throws -> EncodedAudio {
        let padded = Self.paddedMelLength
        let (expectedElements, overflowed) = melBins.multipliedReportingOverflow(by: realFrames)
        guard
            melBins == 128,
            realFrames > 0,
            realFrames <= padded,
            !overflowed,
            melData.count == expectedElements
        else {
            throw AudioModelError.inferenceFailed(
                operation: "CoreML encoder",
                reason: "Invalid mel shape: \(melBins) bins × \(realFrames) frames with \(melData.count) values"
            )
        }
        // Mel input: [1, melBins, paddedMelLength], zero-padded past realFrames.
        let melArray = try MLMultiArray(
            shape: [1, melBins as NSNumber, padded as NSNumber], dataType: .float32)
        let mptr = melArray.dataPointer.assumingMemoryBound(to: Float.self)
        for bin in 0..<melBins {
            let src = bin * realFrames
            let dst = bin * padded
            for t in 0..<realFrames { mptr[dst + t] = melData[src + t] }
            for t in realFrames..<padded { mptr[dst + t] = 0 }
        }
        // mel_length input: [1] int32 with the real (un-padded) frame count.
        let lengthArray = try MLMultiArray(shape: [1], dataType: .int32)
        lengthArray[0] = NSNumber(value: Int32(realFrames))

        let input = try MLDictionaryFeatureProvider(dictionary: [
            "mel": MLFeatureValue(multiArray: melArray),
            "mel_length": MLFeatureValue(multiArray: lengthArray),
        ])
        let output = try model.prediction(from: input)

        guard let embeddings = output.featureValue(for: "audio_embeddings")?.multiArrayValue else {
            throw AudioModelError.inferenceFailed(
                operation: "CoreML encoder", reason: "Missing audio_embeddings output")
        }
        guard let lengthOut = output.featureValue(for: "output_length")?.multiArrayValue else {
            throw AudioModelError.inferenceFailed(
                operation: "CoreML encoder", reason: "Missing output_length output (encoder may be an older export without the chunked-attention mask)")
        }
        let outLen = Self.clampOutputLength(
            Int(lengthOut[0].int32Value),
            embeddingShape: embeddings.shape.map { $0.intValue })
        return EncodedAudio(embeddings: embeddings, outputLength: outLen)
    }

}
#endif
