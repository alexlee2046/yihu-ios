import Foundation

/// Read-only, paired-device payload. Never includes feeds, credentials or reply input.
struct YihuWatchSnapshot: Codable {
    struct Item: Codable, Identifiable {
        var id: String { workbench + ":" + task }
        var workbench: String
        var task: String
        var sourceToken: String? = nil
        var taskToken: String? = nil
        var canDraft: Bool? = nil
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
    var phoneNotificationState: String? = nil
    /// Totals from available phone snapshots, before transport trimming.
    var decisionCount: Int? = nil
    var acceptanceCount: Int? = nil
    var incompleteSources: Bool? = nil

    func count(for status: String) -> Int? {
        guard ["等你决策", "等你验收"].contains(status) else { return nil }
        if let value = status == "等你决策" ? decisionCount : acceptanceCount { return value }
        return truncated ? nil : items.filter { $0.status == status }.count
    }

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
              value.capturedAt.timeIntervalSince1970.isFinite,
              value.sourceDate.map({ $0.timeIntervalSince1970.isFinite }) ?? true,
              (value.decisionCount == nil) == (value.acceptanceCount == nil),
              [value.decisionCount, value.acceptanceCount].allSatisfy({ $0.map { (0...1_000_000).contains($0) } ?? true }),
              value.decisionCount.map({ $0 >= value.items.filter { $0.status == "等你决策" }.count }) ?? true,
              value.acceptanceCount.map({ $0 >= value.items.filter { $0.status == "等你验收" }.count }) ?? true,
              value.items.allSatisfy({ UUID(uuidString: $0.workbench) != nil && !$0.task.isEmpty &&
                  ([$0.sourceToken, $0.taskToken].allSatisfy { token in token.map { $0.count == 64 && $0.allSatisfy({ "0123456789abcdef".contains($0) }) } ?? true }) &&
                  ["等你决策", "等你验收"].contains($0.status) }) else { throw CocoaError(.fileReadCorruptFile) }
        return value
    }
}
