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

    static let maximumBytes = 24_000
    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CocoaError(.fileReadTooLarge) }
        let draft = try JSONDecoder().decode(Self.self, from: data)
        guard UUID(uuidString: draft.workbench) != nil, !draft.task.isEmpty,
              !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              draft.text.unicodeScalars.count <= 4000,
              [draft.sourceToken, draft.taskToken].allSatisfy({ $0.count == 64 && $0.allSatisfy { "0123456789abcdef".contains($0) } }) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return draft
    }
}
