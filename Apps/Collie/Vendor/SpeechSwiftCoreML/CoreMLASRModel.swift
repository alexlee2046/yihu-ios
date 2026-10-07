// Derived from soniqo/speech-swift ca4daaf9be7cccf230f691e443cd80b7a0bd8d97 (Apache-2.0).
// Locally modified: pack prefix, audio and suffix into shared prefill batches.
#if canImport(CoreML)
import CoreML
import Foundation

/// Full CoreML ASR model: CoreML encoder + CoreML text decoder.
///
/// Runs the entire Qwen3-ASR pipeline on CoreML (Neural Engine + CPU),
/// eliminating the MLX GPU dependency. Requires macOS 15+ / iOS 18+
/// for MLState KV cache support.
public class CoreMLASRModel {
    public let encoder: CoreMLASREncoder
    public let decoder: CoreMLTextDecoder
    public let featureExtractor: WhisperFeatureExtractor
    private var tokenizer: Qwen3Tokenizer?
    /// Tokenized whole-term prefixes of the last term list; rebuilt only when the list changes.
    private var contextPrefixes: (terms: [String], prefixes: [[Int32]])?

    public init(encoder: CoreMLASREncoder, decoder: CoreMLTextDecoder) {
        self.encoder = encoder
        self.decoder = decoder
        self.featureExtractor = WhisperFeatureExtractor()
    }

    public static func load(
        from directory: URL,
        encoderComputeUnits: MLComputeUnits = .all,
        decoderComputeUnits: MLComputeUnits = .cpuAndNeuralEngine
    ) throws -> CoreMLASRModel {
        let encoder = try CoreMLASREncoder.load(from: directory, computeUnits: encoderComputeUnits)
        let decoder = try CoreMLTextDecoder.load(from: directory, computeUnits: decoderComputeUnits)
        let model = CoreMLASRModel(encoder: encoder, decoder: decoder)
        let tokenizer = Qwen3Tokenizer()
        try tokenizer.load(from: directory.appendingPathComponent("vocab.json"))
        model.tokenizer = tokenizer
        return model
    }

    /// Warm up both encoder and decoder.
    public func warmUp() throws {
        try Task.checkCancellation()
        try encoder.warmUp()
        try Task.checkCancellation()
        try decoder.warmUp()
    }

    // MARK: - MLX-Free Transcription

    /// Transcribe audio to text without any MLX/Metal dependency.
    ///
    /// Uses `featureExtractor.processRaw()` (CPU via Accelerate) and
    /// `encoder.encode(melData:melBins:timeFrames:)` (CoreML) to produce
    /// MLMultiArray embeddings, then converts them via the dtype/stride-aware
    /// `audioEmbeddingsToFloatArray()`. Prefix, audio and suffix embeddings form
    /// one contiguous prompt, prefilled in shared fixed-size batches.
    ///
    /// This is the only path with no MLXArray operations anywhere, so it is
    /// the one that is safe for iOS background execution — `transcribe()`
    /// still round-trips through MLX for mel extraction and encoder output.
    ///
    /// - Note: Requires `processRaw()` on WhisperFeatureExtractor and
    ///   `encode(melData:melBins:timeFrames:)` on CoreMLASREncoder, both added by T2.
    public func transcribeWithoutMLX(
        audio: [Float],
        sampleRate: Int = 16000,
        language: String? = nil,
        contextTerms: [String] = [],
        maxTokens: Int = 448,
        onPartialText: (@Sendable (String) -> Void)? = nil
    ) throws -> String {
        try Task.checkCancellation()
        // 1. Extract mel features (pure CPU via Accelerate — no MLXArray)
        let melFeatures = try featureExtractor.processRaw(audio, sampleRate: sampleRate)

        try Task.checkCancellation()
        // 2. Encode audio → MLMultiArray embeddings + real (un-padded)
        //    audio-token count from the encoder's ``output_length``.
        let encoded = try encoder.encode(
            melData: melFeatures.data,
            melBins: melFeatures.melBins,
            timeFrames: melFeatures.timeFrames
        )
        let audioEmbeds = encoded.embeddings
        let numAudioTokens = encoded.outputLength

        // All calls are serialized by the owning transcriber actor. Cancellation
        // is checked between Core ML dispatches; never share a cache concurrently.
        try Task.checkCancellation()
        // 3. Reset decoder KV cache
        decoder.resetCache()

        // 4. Build chat template token sequence (identical to transcribe())
        let T = Qwen3ASRTokens.self

        // <|audio_end|><|im_end|>\n<|im_start|>assistant\n
        var suffixTokens: [Int32] = [T.audioEndTokenId, T.imEndTokenId, T.newlineTokenId, T.imStartTokenId, T.assistantTokenId, T.newlineTokenId].map { Int32($0) }

        // Language hint + <asr_text>
        if let lang = language, let tokenizer = tokenizer {
            let langPrefix = "language \(lang)"
            let langTokens = tokenizer.encode(langPrefix)
            suffixTokens += langTokens.map { Int32($0) }
        }
        suffixTokens.append(Int32(T.asrTextTokenId))

        // <|im_start|>system\n{context}<|im_end|>\n — Qwen3-ASR reads system text as
        // background knowledge (e.g. expected terms). Context only gets what the
        // cache can spare after reserving room to transcribe this audio.
        let fixedCount = 5 + 4 + numAudioTokens + suffixTokens.count
        let generationReserve = min(maxTokens, max(64, numAudioTokens))
        if contextPrefixes?.terms != contextTerms {
            contextPrefixes = (contextTerms, Self.contextPrefixes(terms: contextTerms, tokenizer: tokenizer))
        }
        let budget = min(Self.maxContextTokens, decoder.sequenceCapacity - fixedCount - generationReserve)
        let contextTokens = contextPrefixes?.prefixes.last { $0.count <= budget } ?? []
        var prefixTokens: [Int32] = [T.imStartTokenId, T.systemTokenId, T.newlineTokenId].map { Int32($0) }
        prefixTokens += contextTokens
        prefixTokens += [T.imEndTokenId, T.newlineTokenId].map { Int32($0) }
        // <|im_start|>user\n<|audio_start|>
        prefixTokens += [T.imStartTokenId, T.userTokenId, T.newlineTokenId, T.audioStartTokenId].map { Int32($0) }

        // 5. Prefill the complete prompt as one contiguous sequence. Prefix,
        // audio and suffix share the same causal decoder/cache: their boundaries
        // do not require separate fixed-T ANE calls. Packing across them avoids
        // up to two mostly-padded dispatches, especially for short recordings.
        // Keep the dtype/stride-aware conversion for both embedding sources;
        // raw Float16 encoder storage must never be read as Float32.
        var promptEmbeddings: [Float] = []
        for token in prefixTokens {
            try Task.checkCancellation()
            let embedding = try decoder.embed(tokenId: token)
            promptEmbeddings.append(contentsOf:
                try decoder.audioEmbeddingsToFloatArray(embedding, count: 1))
        }
        promptEmbeddings.append(contentsOf:
            try decoder.audioEmbeddingsToFloatArray(audioEmbeds, count: numAudioTokens))
        for token in suffixTokens {
            try Task.checkCancellation()
            let embedding = try decoder.embed(tokenId: token)
            promptEmbeddings.append(contentsOf:
                try decoder.audioEmbeddingsToFloatArray(embedding, count: 1))
        }
        let promptCount = prefixTokens.count + numAudioTokens + suffixTokens.count
        // Never let generation run past the cache: that throws and loses the whole pass.
        let generationLimit = max(1, min(maxTokens, decoder.sequenceCapacity - promptCount))
        let chunk = decoder.prefillBatchSize
        var consumed = 0
        var lastLogits: MLMultiArray?
        while consumed < promptCount {
            try Task.checkCancellation()
            let n = min(chunk, promptCount - consumed)
            lastLogits = try decoder.decoderPrefill(
                flatEmbeddings: promptEmbeddings,
                offset: consumed,
                realCount: n,
            )
            consumed += n
        }

        // 7. Autoregressive generation (same EOS note as `transcribe()` —
        // see that path for the background).
        guard var logits = lastLogits else {
            throw AudioModelError.inferenceFailed(operation: "CoreML decoder", reason: "No output logits")
        }

        var generatedTokens: [Int32] = []
        var lastPartialAt: ContinuousClock.Instant?
        var lastPartialText = ""
        func publishPartial(force: Bool = false) throws {
            guard let onPartialText, let tokenizer else { return }
            let now = ContinuousClock.now
            if !force, let lastPartialAt, lastPartialAt.duration(to: now) < .milliseconds(120) { return }
            let text = Self.transcriptText(tokenizer.decode(
                tokens: generatedTokens.map { Int($0) }, completeUTF8Only: true
            ))
            guard !text.isEmpty, text != lastPartialText else { return }
            try Task.checkCancellation()
            onPartialText(text)
            lastPartialText = text
            lastPartialAt = now
        }
        let imEndId: Int32 = 151645
        var nextToken = decoder.argmax(logits: logits)
        if nextToken == imEndId {
            nextToken = decoder.argmax(logits: logits, skipping: imEndId)
        }
        generatedTokens.append(nextToken)
        try publishPartial()

        for _ in 1..<generationLimit {
            try Task.checkCancellation()
            if nextToken == imEndId { break }
            let embedding = try decoder.embed(tokenId: nextToken)
            logits = try decoder.decoderStep(embedding: embedding)
            nextToken = decoder.argmax(logits: logits)
            generatedTokens.append(nextToken)
            try publishPartial()
        }
        // Out of cache before the model finished: fail like an overflow would, never
        // hand back a silently truncated transcript. (The maxTokens cap keeps its old behavior.)
        if nextToken != imEndId, generationLimit < maxTokens, generatedTokens.count >= generationLimit {
            throw AudioModelError.inferenceFailed(
                operation: "CoreML decoder", reason: "Transcript exceeds the decoder cache")
        }

        try Task.checkCancellation()
        try publishPartial(force: true)
        if let tokenizer {
            return Self.transcriptText(tokenizer.decode(tokens: generatedTokens.map { Int($0) }))
        } else {
            return generatedTokens.map { String($0) }.joined(separator: " ")
        }
    }

    static let maxContextTokens = 96

    /// Tokens of the first 1, 2, … whole terms joined by ", ", up to `maxContextTokens`;
    /// a pass picks the longest prefix its budget allows, so a term is never cut.
    static func contextPrefixes(terms: [String], tokenizer: Qwen3Tokenizer?) -> [[Int32]] {
        guard let tokenizer else { return [] }
        var prefixes: [[Int32]] = []
        for count in terms.indices.map({ $0 + 1 }) {
            let tokens = tokenizer.encode(terms.prefix(count).joined(separator: ", ")).map { Int32($0) }
            guard tokens.count <= maxContextTokens else { break }
            prefixes.append(tokens)
        }
        return prefixes
    }

    private static func transcriptText(_ rawText: String) -> String {
        if let range = rawText.range(of: "<asr_text>") {
            return String(rawText[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return rawText
    }
}
#endif
