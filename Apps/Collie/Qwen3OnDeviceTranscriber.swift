@preconcurrency import AVFoundation
import Foundation
import os

actor Qwen3OnDeviceTranscriber: CollieTranscribing {
    typealias ProgressHandler = @Sendable (Double) -> Void

    private let modelStore = Qwen3ModelStore()
    private var model: CoreMLASRModel?
    private var isWarmedUp = false
    /// Bumped by removal so a load suspended across the integrity check cannot resurrect a deleted model.
    private var installGeneration = 0
    /// Outside actor isolation so starting the microphone never waits behind a model load.
    private nonisolated let recognitionTerms = OSAllocatedUnfairLock(initialState: [String]())

    nonisolated func setRecognitionTerms(_ terms: [String]) {
        recognitionTerms.withLock { $0 = terms }
    }

    func isModelDownloaded() async -> Bool {
        await modelStore.isInstalled()
    }

    func downloadModel(progress: @escaping ProgressHandler) async throws {
        try await downloadModel(source: .modelScope, progress: progress)
    }

    func downloadModel(
        source: Qwen3ModelDownloadSource,
        progress: @escaping ProgressHandler
    ) async throws {
        installGeneration += 1
        model = nil
        isWarmedUp = false
        try await modelStore.install(source: source, progress: progress)
    }

    func removeModel() async throws {
        installGeneration += 1
        model = nil
        isWarmedUp = false
        try await modelStore.removeInstalledModel()
    }

    /// Idempotent per loaded model; loading still requires the full SHA-256 gate.
    func validateInstalledModel() async throws {
        try Task.checkCancellation()
        try await loadIfNeeded()
        try Task.checkCancellation()
        guard !isWarmedUp else { return }
        guard let model else { throw Qwen3TranscriberError.modelMissing }
        try autoreleasepool { try model.warmUp() }
        isWarmedUp = true
        try Task.checkCancellation()
    }

    func transcribe(fileURL: URL) async throws -> String {
        try await transcribe(samples: readMonoSamples(fileURL))
    }

    func transcribe(
        samples: [Float], onPartialText: (@Sendable (String) -> Void)? = nil
    ) async throws -> String {
        try Task.checkCancellation()
        guard !samples.isEmpty,
              samples.count <= Int(16_000 * CollieAudioRecorder.maximumDuration),
              samples.allSatisfy(\.isFinite)
        else { throw Qwen3TranscriberError.unsupportedAudio }
        try await loadIfNeeded()
        try Task.checkCancellation()
        guard let model else { throw Qwen3TranscriberError.modelMissing }

        let publish: (@Sendable (String) -> Void)?
        if let onPartialText {
            publish = { text in
                let simplified = CollieTranscriptText.simplified(text).trimmingCharacters(in: .whitespacesAndNewlines)
                if !simplified.isEmpty { onPartialText(simplified) }
            }
        } else { publish = nil }
        let transcript = try autoreleasepool {
            try model.transcribeWithoutMLX(
                audio: samples,
                sampleRate: 16_000,
                // Keep mixed-language recognition. Script is normalized locally,
                // never by inventing an unsupported "Simplified Chinese" hint.
                language: nil,
                contextTerms: recognitionTerms.withLock { $0 },
                maxTokens: 448,
                onPartialText: publish
            )
        }
        isWarmedUp = true
        try Task.checkCancellation()
        let text = CollieTranscriptText.simplified(transcript).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw Qwen3TranscriberError.emptyTranscript }
        return text
    }

    private func loadIfNeeded() async throws {
        guard model == nil else { return }
        let generation = installGeneration
        let installed = await modelStore.isInstalled()
        try Task.checkCancellation()
        guard installed, generation == installGeneration else { throw Qwen3TranscriberError.modelMissing }
        // Another caller may have loaded while the integrity check was suspended.
        guard model == nil else { return }

        do {
            let model = try CoreMLASRModel.load(
                from: modelStore.modelDirectory,
                encoderComputeUnits: .all,
                decoderComputeUnits: .cpuAndNeuralEngine
            )
            self.model = model
        } catch {
            throw Qwen3TranscriberError.modelLoadFailed(error.localizedDescription)
        }
    }

    private func readMonoSamples(_ fileURL: URL) throws -> [Float] {
        let file = try AVAudioFile(forReading: fileURL)
        let format = file.processingFormat
        guard
            format.sampleRate == 16_000,
            format.channelCount == 1,
            file.length > 0,
            file.length <= AVAudioFramePosition(16_000 * CollieAudioRecorder.maximumDuration)
        else {
            throw Qwen3TranscriberError.unsupportedAudio
        }
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else {
            throw Qwen3TranscriberError.unsupportedAudio
        }
        try file.read(into: buffer)
        guard let channel = buffer.floatChannelData?.pointee else {
            throw Qwen3TranscriberError.unsupportedAudio
        }
        return Array(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength)))
    }
}

enum Qwen3TranscriberError: LocalizedError {
    case modelMissing
    case modelLoadFailed(String)
    case unsupportedAudio
    case emptyTranscript

    var errorDescription: String? {
        switch self {
        case .modelMissing:
            return NSLocalizedString("Qwen3-ASR 模型尚未下载。", tableName: "Yihu", comment: "")
        case .modelLoadFailed(let detail):
            return String(format: NSLocalizedString("Qwen3-ASR 模型无法加载：%@", tableName: "Yihu", comment: ""), detail)
        case .unsupportedAudio:
            return NSLocalizedString("录音格式无法读取，请重新录音。", tableName: "Yihu", comment: "")
        case .emptyTranscript:
            return NSLocalizedString("没有识别到语音，请再试一次。", tableName: "Yihu", comment: "")
        }
    }
}
