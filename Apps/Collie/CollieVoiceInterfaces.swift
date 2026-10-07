import Foundation

enum Qwen3ModelDownloadSource: String, CaseIterable, Identifiable, Sendable {
    case modelScope
    case huggingFace

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .modelScope: NSLocalizedString("国内源", tableName: "Yihu", comment: "")
        case .huggingFace: NSLocalizedString("海外源", tableName: "Yihu", comment: "")
        }
    }

    var providerLabel: String {
        switch self {
        case .modelScope: "ModelScope"
        case .huggingFace: "Hugging Face"
        }
    }

    var detail: String {
        switch self {
        case .modelScope: NSLocalizedString("适合中国大陆网络", tableName: "Yihu", comment: "")
        case .huggingFace: NSLocalizedString("适合中国大陆以外网络", tableName: "Yihu", comment: "")
        }
    }
}

/// Audio stays in bounded, 16 kHz mono PCM memory until this recording ends.
@MainActor
protocol CollieAudioCapturing: AnyObject {
    var onCaptureCompleted: ((Result<[Float], Error>) -> Void)? { get set }
    var onLevelChanged: ((Float) -> Void)? { get set }
    var isRecording: Bool { get }
    func requestPermission() async -> Bool
    func start() throws
    func snapshot() throws -> [Float]
    func stop()
    func cancel()
}

protocol CollieTranscribing: Sendable {
    func isModelDownloaded() async -> Bool
    func downloadModel(progress: @escaping @Sendable (Double) -> Void) async throws
    func downloadModel(
        source: Qwen3ModelDownloadSource,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws
    func validateInstalledModel() async throws
    func removeModel() async throws
    /// Terms the recognizer should expect (developer vocabulary); applied from the next pass on.
    func setRecognitionTerms(_ terms: [String])
    /// Complete, replaceable partial strings; only the returned final is deliverable.
    func transcribe(samples: [Float], onPartialText: (@Sendable (String) -> Void)?) async throws -> String
}

extension CollieTranscribing {
    func transcribe(samples: [Float]) async throws -> String {
        try await transcribe(samples: samples, onPartialText: nil)
    }
}

/// The user's expected-vocabulary list, given to Qwen3-ASR as background context.
enum CollieRecognitionTerms {
    static let defaultsKey = "collie.recognition.terms"
    static let maxTerms = 80
    static let maxTermLength = 40

    /// Ordered by priority: the recognizer keeps as many leading terms as its budget allows.
    static let defaults = [
        "Claude", "Claude Code", "Codex", "Pi", "herdr", "Collie", "一呼",
        "PR", "commit", "push", "merge", "rebase", "branch", "worktree", "review", "CI", "deploy",
        "Xcode", "SwiftUI", "Swift", "iOS", "TypeScript", "React", "Next.js", "GitHub",
        "API", "prompt", "token", "bug", "issue", "TestFlight", "Vercel", "Supabase",
        "Infisical", "Tailscale", "Qwen", "DeepSeek",
    ]

    /// One term per line (commas also split); trims, drops blanks/duplicates, caps length and count.
    static func parse(_ text: String) -> [String] {
        var seen = Set<String>()
        var terms: [String] = []
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        for raw in normalized.split(whereSeparator: { "\n,，、;；".contains($0) }) {
            let term = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !term.isEmpty, term.count <= maxTermLength, seen.insert(term.lowercased()).inserted else { continue }
            terms.append(term)
            if terms.count == maxTerms { break }
        }
        return terms
    }

    static func load(from defaults: UserDefaults) -> [String] {
        guard let saved = defaults.stringArray(forKey: defaultsKey) else { return Self.defaults }
        return parse(saved.joined(separator: "\n"))
    }
}
