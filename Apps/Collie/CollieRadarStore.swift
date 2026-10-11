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
    @ObservationIgnored var watchUpdate: (() -> Void)?

    init(defaults: UserDefaults = .standard, directory: URL? = nil) {
        self.defaults = defaults
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask)[0]
            .appendingPathComponent("Radar", isDirectory: true)
        if let data = defaults.data(forKey: key) {
            if let records = try? JSONDecoder().decode([CollieRadarWorkbench].self, from: data),
               Set(records.map(\.id)).count == records.count {
                workbenches = records
            } else {
                configurationError = NSLocalizedString("工作台配置无法读取，原始配置已保留。", tableName: "Yihu", comment: "")
            }
        }
        for item in workbenches {
            let url = cacheURL(item.id)
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            do {
                let handle = try FileHandle(forReadingFrom: url)
                defer { try? handle.close() }
                let data = try handle.read(upToCount: CollieRadarSnapshot.maximumBytes + 1) ?? Data()
                snapshots[item.id] = try CollieRadarSnapshot.decode(data)
            } catch {
                errors[item.id] = NSLocalizedString("本机快照无法读取，请刷新或重新导入。原始文件已保留。", tableName: "Yihu", comment: "")
            }
        }
    }

    func pendingReply(_ id: UUID) -> CollieRadarSnapshot.Action? {
        let file = CollieRadarPendingReply.file(id)
        guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        do {
            let handle = try FileHandle(forReadingFrom: file)
            defer { try? handle.close() }
            let data = try handle.read(upToCount: 40_001) ?? Data()
            guard data.count <= 40_000 else { throw CollieRadarError.tooLarge }
            let saved = try JSONDecoder().decode(CollieRadarPendingReply.self, from: data)
            return CollieRadarSnapshot.Action(project: "", status: saved.target.status, title: saved.target.title,
                                             next: saved.target.next, url: saved.target.url, id: saved.target.id)
        } catch {
            // Still open the recovery sheet, which preserves the corrupt record and blocks writes.
            return CollieRadarSnapshot.Action(project: "", status: nil, title: "", next: "", url: "", id: "")
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

    @discardableResult
    func update(_ proposed: CollieRadarWorkbench) -> Bool {
        guard configurationError == nil,
              let index = workbenches.firstIndex(where: { $0.id == proposed.id }) else { return false }
        var item = proposed
        item.name = String(item.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(48))
        item.source = item.source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !item.name.isEmpty, item.source.isEmpty || CollieRadarFeed.validate(item.source) != nil else {
            errors[item.id] = NSLocalizedString("名称或数据源无效，设置未保存。", tableName: "Yihu", comment: "")
            return false
        }
        let previous = workbenches[index]
        if previous.source.trimmingCharacters(in: .whitespacesAndNewlines) != item.source {
            guard !FileManager.default.fileExists(atPath: CollieRadarPendingReply.file(item.id).path) else {
                errors[item.id] = NSLocalizedString("请先处理回复草稿或待核结果，再更换数据源。", tableName: "Yihu", comment: "")
                return false
            }
            // Never commit a new source while its old cache can reappear on launch.
            do {
                let url = cacheURL(item.id)
                if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
            } catch {
                errors[item.id] = NSLocalizedString("无法清理旧来源快照，数据源未更改。请稍后重试。", tableName: "Yihu", comment: "")
                return false
            }
            sourceRevisions[item.id, default: 0] += 1
            snapshots[item.id] = nil
            errors[item.id] = nil
            item.display.project = ""
            item.display.status = nil
            item.display.priority = nil
        }
        workbenches[index] = item
        persist()
        return true
    }

    func remove(_ id: UUID) {
        guard configurationError == nil else { return }
        guard !FileManager.default.fileExists(atPath: CollieRadarPendingReply.file(id).path) else {
            errors[id] = NSLocalizedString("请先处理回复草稿或待核结果，再删除工作台。", tableName: "Yihu", comment: "")
            return
        }
        workbenches.removeAll { $0.id == id }
        snapshots[id] = nil
        errors[id] = nil
        sourceRevisions[id, default: 0] += 1
        try? FileManager.default.removeItem(at: cacheURL(id))
        persist()
    }

    func move(from offsets: IndexSet, to destination: Int) {
        // Preserve explicit user ordering; favorites are grouped only for display.
        guard configurationError == nil,
              offsets.allSatisfy({ workbenches.indices.contains($0) }),
              (0...workbenches.count).contains(destination) else { return }
        let moving = offsets.sorted().map { workbenches[$0] }
        let adjusted = destination - offsets.filter { $0 < destination }.count
        for index in offsets.sorted(by: >) { workbenches.remove(at: index) }
        workbenches.insert(contentsOf: moving, at: adjusted)
        persist()
    }

    func importSnapshot(_ data: Data, for id: UUID) {
        guard configurationError == nil, workbenches.contains(where: { $0.id == id }) else { return }
        do {
            try store(data, for: id)
            // Only a successful import supersedes an in-flight refresh.
            sourceRevisions[id, default: 0] += 1
        } catch { errors[id] = message(for: error); watchUpdate?() }
    }

    func reportImportError(for id: UUID) {
        guard workbenches.contains(where: { $0.id == id }) else { return }
        errors[id] = NSLocalizedString("无法读取所选快照。", tableName: "Yihu", comment: "")
        watchUpdate?()
    }

    func refresh(_ id: UUID) async {
        guard configurationError == nil,
              let item = workbenches.first(where: { $0.id == id }), !refreshing.contains(id) else { return }
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
        // Full-ledger reads can exceed 18 seconds; include the server's 28-second
        // read deadline plus private-proxy/identity checks and network overhead.
        configuration.timeoutIntervalForRequest = 40
        configuration.timeoutIntervalForResource = 45
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
                // Buffered byte iteration must not monopolize the main actor.
                if data.count.isMultiple(of: 16_384) { await Task.yield() }
            }
            try Task.checkCancellation()
            guard sourceRevisions[id, default: 0] == revision else { return }
            try store(data, for: id)
        } catch {
            guard sourceRevisions[id, default: 0] == revision,
                  workbenches.contains(where: { $0.id == id }), !(error is CancellationError) else { return }
            errors[id] = message(for: error)
            watchUpdate?()
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
        #if os(iOS)
        try data.write(to: cacheURL(id), options: [.atomic, .completeFileProtection])
        #else
        // macOS does not support iOS Data Protection write options (Cocoa 513).
        try data.write(to: cacheURL(id), options: [.atomic])
        #endif
        snapshots[id] = snapshot
        errors[id] = nil
        watchUpdate?()
    }

    private func cacheURL(_ id: UUID) -> URL { directory.appendingPathComponent(id.uuidString + ".json") }
    private func persist() {
        watchUpdate?()
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
