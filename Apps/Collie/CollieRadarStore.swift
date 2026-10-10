import Foundation
import Observation

private final class CollieRadarNoRedirect: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

@MainActor
@Observable
final class CollieRadarStore {
    private(set) var workbenches: [CollieRadarWorkbench] = []
    private(set) var snapshots: [UUID: CollieRadarSnapshot] = [:]
    private(set) var errors: [UUID: String] = [:]
    private(set) var refreshing: Set<UUID> = []
    private(set) var configurationError: String?
    private let defaults: UserDefaults
    private let directory: URL
    private let key = "collie.radar.workbenches.v1"
    private var sourceRevisions: [UUID: Int] = [:]

    init(defaults: UserDefaults = .standard, directory: URL? = nil) {
        self.defaults = defaults
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask)[0]
            .appendingPathComponent("Radar", isDirectory: true)
        if let data = defaults.data(forKey: key) {
            if let records = try? JSONDecoder().decode([CollieRadarWorkbench].self, from: data) {
                workbenches = records
            } else {
                configurationError = NSLocalizedString("工作台配置无法读取，原始配置已保留。", tableName: "Yihu", comment: "")
            }
        }
        for item in workbenches {
            if let data = try? Data(contentsOf: cacheURL(item.id)),
               let snapshot = try? CollieRadarSnapshot.decode(data) { snapshots[item.id] = snapshot }
        }
    }

    var ordered: [CollieRadarWorkbench] {
        workbenches.filter(\.favorite) + workbenches.filter { !$0.favorite }
    }

    @discardableResult
    func add() -> UUID? {
        guard configurationError == nil else { return nil }
        let item = CollieRadarWorkbench()
        workbenches.append(item)
        persist()
        return item.id
    }

    func update(_ item: CollieRadarWorkbench) {
        guard configurationError == nil,
              let index = workbenches.firstIndex(where: { $0.id == item.id }) else { return }
        let previous = workbenches[index]
        if previous.source != item.source {
            sourceRevisions[item.id, default: 0] += 1
            snapshots[item.id] = nil
            errors[item.id] = nil
            try? FileManager.default.removeItem(at: cacheURL(item.id))
        }
        workbenches[index] = item
        persist()
    }

    func remove(_ id: UUID) {
        guard configurationError == nil else { return }
        workbenches.removeAll { $0.id == id }
        snapshots[id] = nil
        errors[id] = nil
        sourceRevisions[id, default: 0] += 1
        try? FileManager.default.removeItem(at: cacheURL(id))
        persist()
    }

    func move(from offsets: IndexSet, to destination: Int) {
        // Preserve explicit user ordering; favorites are grouped only for display.
        guard configurationError == nil else { return }
        let moving = offsets.sorted().map { workbenches[$0] }
        let adjusted = destination - offsets.filter { $0 < destination }.count
        for index in offsets.sorted(by: >) { workbenches.remove(at: index) }
        workbenches.insert(contentsOf: moving, at: adjusted)
        persist()
    }

    func importSnapshot(_ data: Data, for id: UUID) {
        do {
            sourceRevisions[id, default: 0] += 1
            try store(data, for: id)
        } catch { errors[id] = message(for: error) }
    }

    func reportImportError(for id: UUID) {
        errors[id] = NSLocalizedString("无法读取所选快照。", tableName: "Yihu", comment: "")
    }

    func refresh(_ id: UUID) async {
        guard let item = workbenches.first(where: { $0.id == id }), !refreshing.contains(id) else { return }
        guard let url = CollieRadarFeed.validate(item.source) else {
            errors[id] = message(for: CollieRadarError.invalidURL)
            return
        }
        let revision = sourceRevisions[id, default: 0]
        refreshing.insert(id)
        defer { refreshing.remove(id) }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 30
        let session = URLSession(configuration: configuration, delegate: CollieRadarNoRedirect(),
                                 delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (bytes, response) = try await session.bytes(for: request)
            guard let response = response as? HTTPURLResponse else { throw CollieRadarError.invalidSnapshot }
            guard (200...299).contains(response.statusCode) else { throw CollieRadarError.http(response.statusCode) }
            if response.expectedContentLength > Int64(CollieRadarSnapshot.maximumBytes) {
                throw CollieRadarError.tooLarge
            }
            var data = Data()
            for try await byte in bytes {
                try Task.checkCancellation()
                guard data.count < CollieRadarSnapshot.maximumBytes else { throw CollieRadarError.tooLarge }
                data.append(byte)
            }
            guard sourceRevisions[id, default: 0] == revision else { return }
            try store(data, for: id)
        } catch {
            guard sourceRevisions[id, default: 0] == revision,
                  workbenches.contains(where: { $0.id == id }), !(error is CancellationError) else { return }
            errors[id] = message(for: error)
        }
    }

    private func store(_ data: Data, for id: UUID) throws {
        guard workbenches.contains(where: { $0.id == id }) else { return }
        let snapshot = try CollieRadarSnapshot.decode(data)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var excluded = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try excluded.setResourceValues(values)
        try data.write(to: cacheURL(id), options: [.atomic, .completeFileProtection])
        snapshots[id] = snapshot
        errors[id] = nil
    }

    private func cacheURL(_ id: UUID) -> URL { directory.appendingPathComponent(id.uuidString + ".json") }
    private func persist() {
        if let data = try? JSONEncoder().encode(workbenches) { defaults.set(data, forKey: key) }
    }
    private func message(for error: Error) -> String {
        let key: String
        switch error {
        case CollieRadarError.tooLarge: key = "快照不能超过 2 MB。"
        case CollieRadarError.invalidURL: key = "请输入不含账号、参数或密钥的 HTTPS JSON 地址。"
        case let CollieRadarError.http(code):
            return String(format: NSLocalizedString("数据源返回 HTTP %d，原有快照已保留。", tableName: "Yihu", comment: ""), code)
        case CollieRadarError.invalidSnapshot, is DecodingError: key = "不是有效的 PM Radar 快照。"
        default: key = "更新失败，原有快照已保留。"
        }
        return NSLocalizedString(key, tableName: "Yihu", comment: "")
    }
}
