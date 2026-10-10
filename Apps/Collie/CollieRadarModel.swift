import Foundation
import Observation

/// The portable JSON produced by `pm-radar --json`. Task text stays verbatim.
struct CollieRadarSnapshot: Codable {
    struct Action: Codable {
        var project: String
        var status: String?
        var title: String
        var next: String
        var url: String
        var timestamp: Double? = nil
    }

    struct Project: Codable {
        var name: String
        var path: String
        var timestamp: Double
        var message: String
        // Optional explicit task state; legacy code-activity feeds omit it.
        var status: String? = nil
    }

    var date_str: String
    var decisions: [Action]
    var active: [Project]
    var stale: [Project]
    var cold: [Project]

    var projects: [Project] { active + stale + cold }
    var projectNames: [String] {
        Array(Set(decisions.map(\.project) + projects.map(\.path))).sorted()
    }
    func projectName(_ key: String) -> String {
        projects.first(where: { $0.path == key })?.name ?? key
    }
    func taskStatuses(for key: String) -> [String] {
        let explicit = projects.filter { $0.path == key }.compactMap(\.status)
        return Array(Set(explicit + decisions.filter { $0.project == key }.compactMap(\.status)))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.sorted()
    }

    func sortedProjectNames(newestFirst: Bool) -> [String] {
        let timestamps = Dictionary(projects.map { ($0.path, $0.timestamp) }, uniquingKeysWith: { max($0, $1) })
        let names = Dictionary(projects.map { ($0.path, $0.name) }, uniquingKeysWith: { first, _ in first })
        return projectNames.sorted { lhs, rhs in
            if newestFirst, timestamps[lhs, default: 0] != timestamps[rhs, default: 0] {
                return timestamps[lhs, default: 0] > timestamps[rhs, default: 0]
            }
            return (names[lhs] ?? lhs).localizedCompare(names[rhs] ?? rhs) == .orderedAscending
        }
    }
    func matchingActions(display: CollieRadarDisplay) -> [Action] {
        let filtered = decisions.enumerated().filter {
            (display.project.isEmpty || $0.element.project == display.project) &&
            matches([projectName($0.element.project), $0.element.project, $0.element.title,
                     $0.element.status ?? "", $0.element.next], query: display.searchText)
        }
        if display.newestFirst, filtered.contains(where: { $0.element.timestamp == nil }) {
            return filtered.map(\.element)
        }
        return filtered.sorted { lhs, rhs in
            if display.newestFirst {
                let left = lhs.element.timestamp!
                let right = rhs.element.timestamp!
                return left == right ? lhs.offset < rhs.offset : left > right
            }
            let order = lhs.element.title.localizedCompare(rhs.element.title)
            return order == .orderedSame ? lhs.offset < rhs.offset : order == .orderedAscending
        }.map(\.element)
    }

    func matchingProjects(display: CollieRadarDisplay) -> [Project] {
        projects.filter {
            (display.project.isEmpty || $0.path == display.project) &&
            matches([$0.name, $0.path, $0.message, $0.status ?? ""], query: display.searchText)
        }
    }

    func matchingProjectNames(display: CollieRadarDisplay) -> [String] {
        let keys = Set(matchingActions(display: display).map(\.project) + matchingProjects(display: display).map(\.path))
        return sortedProjectNames(newestFirst: display.newestFirst).filter { keys.contains($0) }
    }

    private func matches(_ fields: [String], query: String?) -> Bool {
        let query = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty || fields.contains { $0.localizedStandardContains(query) }
    }

    var generatedAt: Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: date_str)
    }
    var isOutdated: Bool {
        guard let generatedAt else { return true }
        return Date().timeIntervalSince(generatedAt) > 24 * 3600
    }

    static let maximumBytes = 2 * 1024 * 1024
    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CollieRadarError.tooLarge }
        let snapshot = try JSONDecoder().decode(Self.self, from: data)
        guard snapshot.generatedAt != nil else { throw CollieRadarError.invalidSnapshot }
        return snapshot
    }
}

/// Classify only explicit task states, never code activity or snapshot age.
enum CollieRadarTaskState {
    case progressing, waiting, blocked, unknown

    static func classify(_ status: String) -> Self {
        switch status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "进行中", "推进中", "in progress", "in_progress": return .progressing
        case "等你决策", "等你验收", "等你处理", "等人操作", "等待反馈", "待我处理", "waiting", "pending": return .waiting
        case "真实阻塞", "阻塞", "已阻塞", "blocked": return .blocked
        default: return .unknown
        }
    }

    var icon: String {
        switch self {
        case .progressing: return "arrow.right.circle"
        case .waiting: return "hand.raised"
        case .blocked: return "exclamationmark.octagon"
        case .unknown: return "questionmark.circle"
        }
    }
}

enum CollieRadarError: Error {
    case tooLarge, invalidSnapshot, invalidURL, http(Int)
}

struct CollieRadarDisplay: Codable, Equatable {
    enum Page: String, Codable, CaseIterable { case overview, projects, actions }
    var page: Page = .overview
    var project = ""
    // Optional so existing saved views decode without a migration or reset.
    var searchText: String? = nil
    var compact = false
    var showNext = true
    var showStatus = true
    var showActivity = true
    var newestFirst = true
}

struct CollieRadarWorkbench: Codable, Identifiable, Equatable {
    var id = UUID()
    var name = "PM Radar"
    var source = ""
    var favorite = false
    var display = CollieRadarDisplay()
}

/// Shared ordering across web and native workbenches. Nil means show all on
/// first use; an explicitly empty list means the user hid every shortcut.
@MainActor
@Observable
final class CollieWorkbenchShortcuts {
    private(set) var saved: [String]?
    private let defaults: UserDefaults
    private let key = "collie.workbench.shortcuts.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        saved = defaults.stringArray(forKey: key)
    }

    func visible(available: [String]) -> [String] {
        var seen = Set<String>()
        return (saved ?? available).filter { available.contains($0) && seen.insert($0).inserted }
    }

    func set(_ ids: [String]) {
        var seen = Set<String>()
        saved = ids.filter { seen.insert($0).inserted }
        defaults.set(saved, forKey: key)
    }

    func move(from offsets: IndexSet, to destination: Int, available: [String]) {
        var ids = visible(available: available)
        guard offsets.allSatisfy({ ids.indices.contains($0) }), (0...ids.count).contains(destination) else { return }
        let moving = offsets.sorted().map { ids[$0] }
        let adjusted = destination - offsets.filter { $0 < destination }.count
        for index in offsets.sorted(by: >) { ids.remove(at: index) }
        ids.insert(contentsOf: moving, at: adjusted)
        set(ids)
    }
}

/// A feed can have a path, unlike a trusted browser origin; credentials and
/// query strings must not be smuggled into URLs or silently forwarded.
enum CollieRadarFeed {
    static func validate(_ raw: String) -> URL? {
        guard let parts = URLComponents(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              parts.scheme?.lowercased() == "https", let host = parts.host, !host.isEmpty,
              parts.user == nil, parts.password == nil, parts.query == nil, parts.fragment == nil,
              parts.port.map({ (1...65535).contains($0) }) ?? true else { return nil }
        return parts.url
    }
}
