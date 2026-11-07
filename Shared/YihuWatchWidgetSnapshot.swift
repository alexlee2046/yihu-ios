import Foundation

/// The widget gets counts and freshness only, never titles, origins, task IDs or drafts.
struct YihuWatchWidgetSnapshot: Codable, Sendable {
    var decisionCount: Int?
    var acceptanceCount: Int?
    var sourceDate: Date?
    var hasSource: Bool
    var readFailed: Bool
    var incompleteSources: Bool

    init(_ snapshot: YihuWatchSnapshot) {
        decisionCount = snapshot.count(for: "等你决策")
        acceptanceCount = snapshot.count(for: "等你验收")
        sourceDate = snapshot.sourceDate
        hasSource = snapshot.hasSource
        readFailed = snapshot.readFailed
        incompleteSources = snapshot.incompleteSources ?? false
    }
    var total: Int? {
        guard let decisionCount, let acceptanceCount else { return nil }
        return decisionCount + acceptanceCount
    }
    func needsRefresh(at date: Date) -> Bool {
        guard hasSource, let sourceDate else { return true }
        let age = date.timeIntervalSince(sourceDate)
        return readFailed || incompleteSources || age >= 86400 || age < -300
    }
    func status(at date: Date) -> String {
        if !hasSource { return "请在手机同步" }
        if incompleteSources { return "部分来源待刷新" }
        if needsRefresh(at: date) { return "数据待刷新" }
        if total == nil { return "数量不完整" }
        return "手机已有数据"
    }
    static let maximumBytes = 2048
    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CocoaError(.fileReadTooLarge) }
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard (value.decisionCount == nil) == (value.acceptanceCount == nil),
              [value.decisionCount, value.acceptanceCount].allSatisfy({ $0.map { (0...1_000_000).contains($0) } ?? true }),
              value.sourceDate.map({ $0.timeIntervalSince1970.isFinite }) ?? true else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return value
    }
}

/// A watch-local App Group; WatchConnectivity is still the only phone transport.
enum YihuWatchWidgetStore {
    static let kind = "YihuWatchActions"
    static var file: URL? {
        #if os(watchOS)
        guard let group = Bundle.main.object(forInfoDictionaryKey: "YihuAppGroup") as? String,
              let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else { return nil }
        return root.appendingPathComponent("WatchWidget/counts.json")
        #else
        return nil
        #endif
    }
    static func load(from file: URL?) -> YihuWatchWidgetSnapshot? {
        guard let file, let handle = try? FileHandle(forReadingFrom: file) else { return nil }
        defer { try? handle.close() }
        guard let data = try? handle.read(upToCount: YihuWatchWidgetSnapshot.maximumBytes + 1) else { return nil }
        return try? YihuWatchWidgetSnapshot.decode(data)
    }
    static func save(_ snapshot: YihuWatchWidgetSnapshot, to file: URL?) throws {
        guard let file else { throw CocoaError(.fileNoSuchFile) }
        let data = try JSONEncoder().encode(snapshot)
        _ = try YihuWatchWidgetSnapshot.decode(data)
        let directory = file.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var excluded = directory
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try excluded.setResourceValues(values)
        try data.write(to: file, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}

enum YihuWatchRoute: String, CaseIterable {
    case all, decision, acceptance
    var status: String? {
        switch self {
        case .all: nil
        case .decision: "等你决策"
        case .acceptance: "等你验收"
        }
    }
    var url: URL { URL(string: "yihu-watch://actions/\(rawValue)")! }
    init?(url: URL) {
        guard url.scheme == "yihu-watch", url.host == "actions", url.query == nil, url.fragment == nil,
              let route = Self(rawValue: String(url.path.dropFirst())) else { return nil }
        self = route
    }
}
