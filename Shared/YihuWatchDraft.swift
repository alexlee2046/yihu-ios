import Foundation

/// A proposal only. This payload never authorizes a ledger write.
struct YihuWatchDraft: Codable {
    var requestID: UUID
    var workbench: String
    var task: String
    var sourceToken: String
    var taskToken: String
    var text: String
    var transferAttempted: Bool? = nil
    /// A phone persistence acknowledgement, never a ledger receipt.
    var phoneSaved: Bool? = nil
    var title: String? = nil

    func matches(_ item: YihuWatchSnapshot.Item) -> Bool {
        workbench == item.workbench && task == item.task &&
            sourceToken == item.sourceToken && taskToken == item.taskToken
    }

    static let maximumBytes = 24_000
    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CocoaError(.fileReadTooLarge) }
        let draft = try JSONDecoder().decode(Self.self, from: data)
        guard UUID(uuidString: draft.workbench) != nil, !draft.task.isEmpty,
              !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              draft.text.unicodeScalars.count <= 4000,
              (draft.title?.count ?? 0) <= 160,
              draft.phoneSaved != true || draft.transferAttempted != false,
              [draft.sourceToken, draft.taskToken].allSatisfy({ $0.count == 64 && $0.allSatisfy { "0123456789abcdef".contains($0) } }) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return draft
    }
}

/// The existing single protected draft, also readable without a live task row.
struct YihuWatchDraftStore {
    let file: URL
    static var local: Self {
        .init(file: URL.applicationSupportDirectory.appendingPathComponent("watch-proposal.json"))
    }
    func load() throws -> YihuWatchDraft? {
        guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        let handle = try FileHandle(forReadingFrom: file)
        defer { try? handle.close() }
        return try YihuWatchDraft.decode(handle.read(upToCount: YihuWatchDraft.maximumBytes + 1) ?? Data())
    }
    func save(_ draft: YihuWatchDraft) throws {
        let data = try JSONEncoder().encode(draft)
        _ = try YihuWatchDraft.decode(data)
        if let prior = try load() {
            guard prior.requestID == draft.requestID, prior.workbench == draft.workbench,
                  prior.task == draft.task, prior.sourceToken == draft.sourceToken,
                  prior.taskToken == draft.taskToken,
                  prior.transferAttempted == false || (prior.text == draft.text && draft.transferAttempted != false),
                  prior.phoneSaved != true || draft.phoneSaved == true else {
                throw CocoaError(.fileWriteFileExists)
            }
        }
        let directory = file.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var excluded = directory
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try excluded.setResourceValues(values)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
    }
    func clear() throws {
        if FileManager.default.fileExists(atPath: file.path) { try FileManager.default.removeItem(at: file) }
    }
}

enum YihuWatchQuickDraft {
    static let templates = ["请补充验收证据。", "请说明影响范围。", "我稍后处理，请先保留当前状态。"]
    /// Never append to, replace, or unlock an existing input.
    static func canApply(text: String, locked: Bool) -> Bool { text.isEmpty && !locked }
}
