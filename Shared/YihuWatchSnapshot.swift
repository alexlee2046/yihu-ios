import Foundation

/// Read-only, paired-device payload. Never includes feeds, credentials or reply input.
struct YihuWatchSnapshot: Codable {
    struct Item: Codable, Identifiable {
        var id: String { workbench + ":" + task }
        var workbench: String
        var task: String
        var sourceToken: String? = nil
        var title: String
        var project: String
        var status: String
        var priority: String
        var next: String
        var sourceDate: Date?
        var readFailed: Bool

        var stale: Bool {
            guard let sourceDate else { return true }
            let age = Date().timeIntervalSince(sourceDate)
            return readFailed || age > 86400 || age < -300
        }
    }
    var items: [Item]
    var capturedAt: Date
    var truncated: Bool
    var hasSource: Bool
    var sourceDate: Date? = nil
    var readFailed = false

    var stale: Bool {
        guard let sourceDate else { return true }
        let age = Date().timeIntervalSince(sourceDate)
        return readFailed || age > 86400 || age < -300
    }

    static let maximumBytes = 50_000
    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CocoaError(.fileReadTooLarge) }
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard value.items.count <= 200, Set(value.items.map(\.id)).count == value.items.count,
              value.items.allSatisfy({ UUID(uuidString: $0.workbench) != nil && !$0.task.isEmpty &&
                  ($0.sourceToken.map { token in token.count == 64 && token.allSatisfy({ "0123456789abcdef".contains($0) }) } ?? true) &&
                  ["等你决策", "等你验收"].contains($0.status) }) else { throw CocoaError(.fileReadCorruptFile) }
        return value
    }
}
