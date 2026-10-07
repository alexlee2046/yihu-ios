import Foundation
import UniformTypeIdentifiers

/// Items shared into 一呼 from other apps (share sheet or "Open in"), waiting in
/// the App Group container until the user inserts them into a workbench.
/// Shared by the app and the share extension; extension-API-safe.
struct CollieSharedItem: Codable, Equatable, Identifiable, Sendable {
    enum Kind: String, Codable, Sendable { case text, url, file }

    var id = UUID()
    var kind: Kind
    /// Text body, or the absolute URL string for `.url`.
    var text: String?
    /// File name inside the batch directory, for `.file`.
    var fileName: String?
    var contentType: String?
    var byteCount: Int64?

    var displayName: String {
        switch kind {
        case .text: return text.map { String($0.prefix(40)) } ?? ""
        case .url: return text ?? ""
        case .file: return fileName ?? NSLocalizedString("文件", tableName: "Yihu", comment: "")
        }
    }
}

struct CollieShareBatch: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var createdAt = Date()
    var items: [CollieSharedItem] = []
}

enum CollieShareInboxError: LocalizedError {
    case unavailable, tooLarge

    var errorDescription: String? {
        switch self {
        case .unavailable: return NSLocalizedString("无法访问一呼的共享收件箱。", tableName: "Yihu", comment: "")
        case .tooLarge: return String(format: NSLocalizedString("内容太大（单次最多 %lld MB）。", tableName: "Yihu", comment: ""), CollieShareInbox.maxBatchBytes / 1_048_576)
        }
    }
}

struct CollieShareInbox: Sendable {
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "YihuAppGroup") as? String ?? "group.org.example.yihu"
    static let maxBatchBytes: Int64 = 200 * 1_048_576
    private static let manifestName = "manifest.json"

    let root: URL

    init(root: URL) { self.root = root }

    /// The shared App Group inbox; nil if the entitlement is missing.
    static func shared(fileManager: FileManager = .default) -> CollieShareInbox? {
        guard let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else { return nil }
        return CollieShareInbox(root: container.appendingPathComponent("ShareInbox", isDirectory: true))
    }

    func directory(for batch: CollieShareBatch) -> URL {
        root.appendingPathComponent(batch.id.uuidString, isDirectory: true)
    }

    func fileURL(for item: CollieSharedItem, in batch: CollieShareBatch) -> URL? {
        guard item.kind == .file, let name = item.fileName else { return nil }
        return directory(for: batch).appendingPathComponent(name)
    }

    /// Writes a batch: texts/URLs inline, files copied (never moved) into the batch
    /// directory. The manifest is written last so readers never see partial batches.
    func save(texts: [String], urls: [URL], files: [URL]) throws -> CollieShareBatch {
        let fileManager = FileManager.default
        var batch = CollieShareBatch()
        let directory = directory(for: batch)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        do {
            var total: Int64 = 0
            for text in texts where !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                batch.items.append(CollieSharedItem(kind: .text, text: text))
            }
            for url in urls {
                batch.items.append(CollieSharedItem(kind: .url, text: url.absoluteString))
            }
            var usedNames = Set<String>()
            for source in files {
                let size = Self.byteCount(of: source)
                total += size
                guard total <= Self.maxBatchBytes else { throw CollieShareInboxError.tooLarge }
                let name = Self.uniqueName(source.lastPathComponent, used: &usedNames)
                try fileManager.copyItem(at: source, to: directory.appendingPathComponent(name))
                let type = UTType(filenameExtension: source.pathExtension)?.preferredMIMEType
                batch.items.append(CollieSharedItem(kind: .file, fileName: name, contentType: type, byteCount: size))
            }
            guard !batch.items.isEmpty else { throw CollieShareInboxError.unavailable }
            let data = try JSONEncoder().encode(batch)
            try data.write(to: directory.appendingPathComponent(Self.manifestName), options: .atomic)
            return batch
        } catch {
            try? fileManager.removeItem(at: directory)
            throw error
        }
    }

    /// Rewrites a batch's manifest after part of it was placed (e.g. files attached).
    func update(_ batch: CollieShareBatch) throws {
        let data = try JSONEncoder().encode(batch)
        try data.write(to: directory(for: batch).appendingPathComponent(Self.manifestName), options: .atomic)
    }

    /// Removes batch directories that never got a manifest (an interrupted share),
    /// once they are old enough that no extension can still be writing them.
    func sweepIncomplete(olderThan age: TimeInterval = 3_600, now: Date = Date()) {
        let fileManager = FileManager.default
        guard let entries = try? fileManager.contentsOfDirectory(
            at: root, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
        for directory in entries
        where !fileManager.fileExists(atPath: directory.appendingPathComponent(Self.manifestName).path) {
            let modified = (try? directory.resourceValues(forKeys: [.contentModificationDateKey]))?
                .contentModificationDate ?? .distantPast
            if now.timeIntervalSince(modified) > age { try? fileManager.removeItem(at: directory) }
        }
    }

    /// Bytes of a file, or of every file inside a directory/package.
    static func byteCount(of url: URL) -> Int64 {
        let keys: Set<URLResourceKey> = [.fileSizeKey, .isDirectoryKey]
        let values = try? url.resourceValues(forKeys: keys)
        guard values?.isDirectory == true else { return Int64(values?.fileSize ?? 0) }
        var total: Int64 = 0
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: Array(keys))
        while let child = enumerator?.nextObject() as? URL {
            total += Int64((try? child.resourceValues(forKeys: keys))?.fileSize ?? 0)
        }
        return total
    }

    /// Complete batches, oldest first.
    func pending() -> [CollieShareBatch] {
        let fileManager = FileManager.default
        guard let entries = try? fileManager.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
        else { return [] }
        return entries.compactMap { directory -> CollieShareBatch? in
            guard let data = try? Data(contentsOf: directory.appendingPathComponent(Self.manifestName)) else { return nil }
            return try? JSONDecoder().decode(CollieShareBatch.self, from: data)
        }
        .sorted { $0.createdAt < $1.createdAt }
    }

    func remove(_ batch: CollieShareBatch) {
        try? FileManager.default.removeItem(at: directory(for: batch))
    }

    static func uniqueName(_ proposed: String, used: inout Set<String>) -> String {
        let cleaned = proposed.replacingOccurrences(of: "/", with: "_")
        let safe = cleaned.isEmpty ? "file" : cleaned
        var candidate = safe
        var counter = 2
        let base = (safe as NSString).deletingPathExtension
        let ext = (safe as NSString).pathExtension
        while used.contains(candidate.lowercased()) {
            candidate = ext.isEmpty ? "\(base) \(counter)" : "\(base) \(counter).\(ext)"
            counter += 1
        }
        used.insert(candidate.lowercased())
        return candidate
    }
}
