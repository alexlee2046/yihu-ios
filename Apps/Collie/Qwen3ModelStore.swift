import CryptoKit
import Foundation

enum Qwen3ModelSource: Sendable {
    case coreML
    case tokenizer
}

struct Qwen3ModelAsset: Sendable {
    let path: String
    let byteCount: Int64
    let sha256: String
    let source: Qwen3ModelSource
}

private struct Qwen3DownloadedChunk: Sendable {
    let index: Int
    let url: URL
    let byteCount: Int64
}

actor Qwen3ModelStore {
    typealias ProgressHandler = @Sendable (Double) -> Void
    private typealias ByteProgressHandler = @Sendable (Int64) -> Void

    // Pin each provider's repository revisions and every asset hash: inference never executes mutable weights.
    private static let revision = "modelscope-50c8480c626116e21c9353d788762743cd401f24-tokenizer-4ce9cc728b473a5aedbe7b6e1ea45646316824dc"
    private static let coreMLRevision = "50c8480c626116e21c9353d788762743cd401f24"
    private static let tokenizerRevision = "4ce9cc728b473a5aedbe7b6e1ea45646316824dc"
    private static let huggingFaceCoreMLRevision = "8c6bc87b87856930b435550e94ce47de710ce4ed"
    private static let huggingFaceTokenizerRevision = "5eb144179a02acc5e5ba31e748d22b0cf3e303b0"
    private static let revisionMarker = ".collie-model-revision"
    private static let segmentThreshold: Int64 = 8 * 1_024 * 1_024
    private static let maximumSegments = 8

    private static let assets: [Qwen3ModelAsset] = [
        .init(path: "config.json", byteCount: 656, sha256: "59ef0abb8eb0f919ab23bd850eca554bc857b70f7d2eb85f4602bf57769bc65c", source: .coreML),
        .init(path: "decoder_part2.mlmodelc/analytics/coremldata.bin", byteCount: 243, sha256: "7d31ea69629894b917576925cfb294254cfba00e6cf5aa39a35bcdd170b9760d", source: .coreML),
        .init(path: "embedding.mlmodelc/coremldata.bin", byteCount: 317, sha256: "1b541633a809478308ec4fc7c229583cfd98558f112b3a2dc454991cea1998c9", source: .coreML),
        .init(path: "decoder_part1.mlmodelc/analytics/coremldata.bin", byteCount: 243, sha256: "de705821a0587cac5a531ed0db0f4fcfb5fbc66dc3456bf1ab587f28f33065ec", source: .coreML),
        .init(path: "encoder.mlmodelc/analytics/coremldata.bin", byteCount: 243, sha256: "604f14af96690891a3545cfcc0f3d0a6082500a40d4acc9f0f58e5ebb31270a8", source: .coreML),
        .init(path: "encoder.mlmodelc/coremldata.bin", byteCount: 376, sha256: "78ab8af5d140777241d425526b15bd1f5ebeab27006565cbae3ad2bbdb197548", source: .coreML),
        .init(path: "decoder_part1.mlmodelc/coremldata.bin", byteCount: 1_263, sha256: "e39a9c89c9fe651729968db2dc570efabe62f51e8e5dd90dd17416adef961293", source: .coreML),
        .init(path: "decoder_part2.mlmodelc/coremldata.bin", byteCount: 1_257, sha256: "63689c12761296dbebf69aaf36b0d99ac1c27ca28148cc4a4f06af10328de8fb", source: .coreML),
        .init(path: "embedding.mlmodelc/analytics/coremldata.bin", byteCount: 243, sha256: "ff5abcfdb13eab9fd720c620bddcba6cc7627629435bd603d1301e14a8df4993", source: .coreML),
        .init(path: "embedding.mlmodelc/metadata.json", byteCount: 1_589, sha256: "90d988d5c78e9bfa4e853422faf4a1480c736a987d5c958ad782ec1a7ad3ed69", source: .coreML),
        .init(path: "encoder.mlmodelc/metadata.json", byteCount: 2_736, sha256: "66cdade9160073abac8cade3a3950a6683da203cc34d50a6efd3753edfe62069", source: .coreML),
        .init(path: "decoder_part2.mlmodelc/metadata.json", byteCount: 10_416, sha256: "267889b12ac78d58659f9ef5741aefeaa08bc5de59975fde3661a9865483ba47", source: .coreML),
        .init(path: "decoder_part1.mlmodelc/metadata.json", byteCount: 10_422, sha256: "267ad7a71a7b84b908e8a56557a41429f5c9bc8129253870dbf302c41482a320", source: .coreML),
        .init(path: "decoder_part1.mlmodelc/model.mil", byteCount: 391_638, sha256: "b9e532c1b198238a073f323de97b23fea953d16cf3d6e1e705e4af7f51270cd3", source: .coreML),
        .init(path: "embedding.mlmodelc/model.mil", byteCount: 1_161, sha256: "8cc48f12759c33c11407ee4ace5008d8be0a382d8afa16862e28d963156bad9b", source: .coreML),
        .init(path: "decoder_part2.mlmodelc/model.mil", byteCount: 394_840, sha256: "a98a60466dfed5df20f285129ea72f64a607cb03d3cd755d0396af43ec89f550", source: .coreML),
        .init(path: "encoder.mlmodelc/model.mil", byteCount: 1_298_756, sha256: "3d501a96cbbd09644b9c48eafb030f0d7a59785c0766ded72b3c43a0a7d6d2ff", source: .coreML),
        .init(path: "encoder.mlmodelc/weights/weight.bin", byteCount: 186_844_416, sha256: "e935d3ce19a529ef560b2e3be4c0180a571e74975f7db80d91ad13226748d250", source: .coreML),
        .init(path: "embedding.mlmodelc/weights/weight.bin", byteCount: 155_583_168, sha256: "9c7ffa77178d5b7e6fa571ebb8e0fd40b6380d342139889958af56241f2d4e1f", source: .coreML),
        .init(path: "decoder_part1.mlmodelc/weights/weight.bin", byteCount: 220_344_512, sha256: "10111bd2c90c7be3d3dd87294e03b0a766f079d5516a691d6ea349cd6981ae71", source: .coreML),
        .init(path: "decoder_part2.mlmodelc/weights/weight.bin", byteCount: 376_233_664, sha256: "c42e4ab573e118f5da7bd599f35fcbc17a5f188433418ad1793ed474c55df092", source: .coreML),
        .init(path: "merges.txt", byteCount: 1_671_853, sha256: "8831e4f1a044471340f7c0a83d7bd71306a5b867e95fd870f74d0c5308a904d5", source: .tokenizer),
        .init(path: "tokenizer_config.json", byteCount: 12_487, sha256: "4942d005604266809309cabc9f4e9cb89ce855d59b14681fdc0e1cc62ea26c4c", source: .tokenizer),
        .init(path: "vocab.json", byteCount: 2_776_833, sha256: "ca10d7e9fb3ed18575dd1e277a2579c16d108e32f27439684afa0e10b1440910", source: .tokenizer),
    ]

    nonisolated let modelDirectory = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("CollieModels/Qwen3-ASR-CoreML", isDirectory: true)
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 300
        configuration.timeoutIntervalForResource = 7_200
        configuration.httpMaximumConnectionsPerHost = Self.maximumSegments
        session = URLSession(configuration: configuration)
    }

    func isInstalled() -> Bool {
        guard !Task.isCancelled else { return false }
        let marker = modelDirectory.appendingPathComponent(Self.revisionMarker)
        guard
            let installedRevision = try? String(contentsOf: marker, encoding: .utf8),
            installedRevision == Self.revision
        else { return false }

        return Self.assets.allSatisfy { asset in
            let url = modelDirectory.appendingPathComponent(asset.path)
            guard
                !Task.isCancelled,
                let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
                Int64(values.fileSize ?? -1) == asset.byteCount,
                let digest = try? sha256(of: url)
            else { return false }
            return digest == asset.sha256
        }
    }

    func install(
        source: Qwen3ModelDownloadSource = .modelScope,
        progress: @escaping ProgressHandler
    ) async throws {
        try Task.checkCancellation()
        if isInstalled() {
            try Task.checkCancellation()
            try excludeFromBackup(modelDirectory)
            progress(1)
            return
        }

        try Task.checkCancellation()
        let fileManager = FileManager.default
        let parent = modelDirectory.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        try excludeFromBackup(parent)
        try removeStaleStagingDirectories(in: parent)

        let staging = parent.appendingPathComponent(
            ".int8-staging-\(UUID().uuidString)",
            isDirectory: true
        )
        try fileManager.createDirectory(at: staging, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: staging) }

        let totalBytes = Self.assets.reduce(Int64(0)) { $0 + $1.byteCount }
        var completedBytes: Int64 = 0

        for asset in Self.assets {
            try Task.checkCancellation()
            let completedBeforeAsset = completedBytes
            let destination = staging.appendingPathComponent(asset.path)
            try await download(asset, from: source, to: destination) { assetBytes in
                progress(Double(completedBeforeAsset + assetBytes) / Double(totalBytes))
            }
            completedBytes += asset.byteCount
        }

        try Task.checkCancellation()
        try Self.revision.write(
            to: staging.appendingPathComponent(Self.revisionMarker),
            atomically: true,
            encoding: .utf8
        )
        try excludeFromBackup(staging)

        // Nothing reads this directory until the actor returns. Publish only the fully verified tree,
        // replacing an incomplete/older cache with one filesystem operation when one exists.
        if fileManager.fileExists(atPath: modelDirectory.path) {
            _ = try fileManager.replaceItemAt(modelDirectory, withItemAt: staging)
        } else {
            try fileManager.moveItem(at: staging, to: modelDirectory)
        }
        try excludeFromBackup(modelDirectory)
        progress(1)
    }

    func removeInstalledModel() throws {
        if FileManager.default.fileExists(atPath: modelDirectory.path) {
            try FileManager.default.removeItem(at: modelDirectory)
        }
    }

    private func download(
        _ asset: Qwen3ModelAsset,
        from source: Qwen3ModelDownloadSource,
        to destination: URL,
        progress: @escaping ByteProgressHandler
    ) async throws {
        var lastError: Error = Qwen3ModelStoreError.downloadRejected(asset.path)

        for remoteURL in Self.sourceURLs(for: asset, source: source) {
            try? FileManager.default.removeItem(at: destination)
            do {
                try FileManager.default.createDirectory(
                    at: destination.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                if asset.byteCount >= Self.segmentThreshold {
                    try await downloadInSegments(asset, from: remoteURL, to: destination, progress: progress)
                } else {
                    try await downloadSingleFile(asset, from: remoteURL, to: destination)
                    progress(asset.byteCount)
                }

                let downloadedBytes = try destination.resourceValues(forKeys: [.fileSizeKey]).fileSize
                guard Int64(downloadedBytes ?? -1) == asset.byteCount else {
                    throw Qwen3ModelStoreError.sizeMismatch(asset.path)
                }
                guard try sha256(of: destination) == asset.sha256 else {
                    throw Qwen3ModelStoreError.hashMismatch(asset.path)
                }
                return
            } catch {
                try Task.checkCancellation() // Cancellation must not try another source.
                lastError = error
                try? FileManager.default.removeItem(at: destination)
            }
        }

        throw lastError
    }

    private func downloadSingleFile(_ asset: Qwen3ModelAsset, from remoteURL: URL, to destination: URL) async throws {
        var request = URLRequest(url: remoteURL, timeoutInterval: 600)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (temporaryURL, response) = try await session.download(for: request)
        guard let http = response as? HTTPURLResponse, [200, 206].contains(http.statusCode) else {
            throw Qwen3ModelStoreError.downloadRejected(asset.path)
        }
        try FileManager.default.moveItem(at: temporaryURL, to: destination)
    }

    private func downloadInSegments(
        _ asset: Qwen3ModelAsset,
        from remoteURL: URL,
        to destination: URL,
        progress: @escaping ByteProgressHandler
    ) async throws {
        let fileManager = FileManager.default
        let chunkDirectory = destination.deletingLastPathComponent().appendingPathComponent(
            ".chunks-\(UUID().uuidString)",
            isDirectory: true
        )
        try fileManager.createDirectory(at: chunkDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: chunkDirectory) }

        let segmentCount = Self.maximumSegments
        let segmentSize = (asset.byteCount + Int64(segmentCount) - 1) / Int64(segmentCount)
        var chunks: [Qwen3DownloadedChunk] = []
        var downloadedBytes: Int64 = 0

        try await withThrowingTaskGroup(of: Qwen3DownloadedChunk.self) { group in
            for index in 0..<segmentCount {
                let lowerBound = Int64(index) * segmentSize
                guard lowerBound < asset.byteCount else { continue }
                let upperBound = min(asset.byteCount - 1, lowerBound + segmentSize - 1)
                let expectedBytes = upperBound - lowerBound + 1

                group.addTask { [session] in
                    var lastError: Error = Qwen3ModelStoreError.downloadRejected(asset.path)
                    for attempt in 0..<3 {
                        do {
                            var request = URLRequest(url: remoteURL, timeoutInterval: 600)
                            request.cachePolicy = .reloadIgnoringLocalCacheData
                            request.setValue("bytes=\(lowerBound)-\(upperBound)", forHTTPHeaderField: "Range")
                            let (temporaryURL, response) = try await session.download(for: request)
                            guard let http = response as? HTTPURLResponse, http.statusCode == 206 else {
                                throw Qwen3ModelStoreError.rangeUnsupported(asset.path)
                            }
                            let actualBytes = try temporaryURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
                            guard Int64(actualBytes ?? -1) == expectedBytes else {
                                throw Qwen3ModelStoreError.sizeMismatch(asset.path)
                            }
                            let chunkURL = chunkDirectory.appendingPathComponent("\(index).part")
                            try FileManager.default.moveItem(at: temporaryURL, to: chunkURL)
                            return Qwen3DownloadedChunk(index: index, url: chunkURL, byteCount: expectedBytes)
                        } catch {
                            lastError = error
                            if attempt < 2 {
                                try await Task.sleep(for: .seconds(attempt + 1))
                            }
                        }
                    }
                    throw lastError
                }
            }

            for try await chunk in group {
                chunks.append(chunk)
                downloadedBytes += chunk.byteCount
                progress(downloadedBytes)
            }
        }

        guard fileManager.createFile(atPath: destination.path, contents: nil) else {
            throw Qwen3ModelStoreError.couldNotAssemble(asset.path)
        }
        let output = try FileHandle(forWritingTo: destination)
        defer { try? output.close() }

        for chunk in chunks.sorted(by: { $0.index < $1.index }) {
            do {
                let input = try FileHandle(forReadingFrom: chunk.url)
                defer { try? input.close() }
                while let data = try input.read(upToCount: 1_048_576), !data.isEmpty {
                    try output.write(contentsOf: data)
                }
            }
            try fileManager.removeItem(at: chunk.url)
        }
    }

    private func removeStaleStagingDirectories(in parent: URL) throws {
        let children = try FileManager.default.contentsOfDirectory(
            at: parent,
            includingPropertiesForKeys: nil,
            options: []
        )
        for child in children where child.lastPathComponent.hasPrefix(".int8-staging-") {
            try FileManager.default.removeItem(at: child)
        }
    }

    // Internal so a focused test can cancel a real file scan without model weights.
    // Never return a partial digest: cancellation keeps the integrity gate closed.
    func sha256(of url: URL) throws -> String {
        try Task.checkCancellation()
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        var hasher = SHA256()
        while true {
            try Task.checkCancellation()
            guard let chunk = try handle.read(upToCount: 1_048_576), !chunk.isEmpty else { break }
            try Task.checkCancellation()
            hasher.update(data: chunk)
        }
        try Task.checkCancellation()
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func excludeFromBackup(_ url: URL) throws {
        var mutableURL = url
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try mutableURL.setResourceValues(values)
    }

    private static func sourceURLs(
        for asset: Qwen3ModelAsset,
        source: Qwen3ModelDownloadSource
    ) -> [URL] {
        let repository: String
        let sourceRevision: String
        switch asset.source {
        case .coreML:
            repository = "aufklarer/Qwen3-ASR-CoreML"
            sourceRevision = source == .modelScope ? coreMLRevision : huggingFaceCoreMLRevision
        case .tokenizer:
            repository = "Qwen/Qwen3-ASR-0.6B"
            sourceRevision = source == .modelScope ? tokenizerRevision : huggingFaceTokenizerRevision
        }

        switch source {
        case .modelScope:
            return ["https://modelscope.cn", "https://www.modelscope.cn"].compactMap { host in
                URL(string: "\(host)/models/\(repository)/resolve/\(sourceRevision)/\(asset.path)")
            }
        case .huggingFace:
            return [URL(string: "https://huggingface.co/\(repository)/resolve/\(sourceRevision)/\(asset.path)")].compactMap { $0 }
        }
    }
}

enum Qwen3ModelStoreError: LocalizedError {
    case downloadRejected(String)
    case rangeUnsupported(String)
    case sizeMismatch(String)
    case hashMismatch(String)
    case couldNotAssemble(String)

    var errorDescription: String? {
        switch self {
        case .downloadRejected(let path):
            return String(format: NSLocalizedString("模型下载被服务器拒绝：%@", tableName: "Yihu", comment: ""), path)
        case .rangeUnsupported(let path):
            return String(format: NSLocalizedString("模型下载服务器不支持分段：%@", tableName: "Yihu", comment: ""), path)
        case .sizeMismatch(let path):
            return String(format: NSLocalizedString("模型文件大小校验失败：%@", tableName: "Yihu", comment: ""), path)
        case .hashMismatch(let path):
            return String(format: NSLocalizedString("模型文件完整性校验失败：%@", tableName: "Yihu", comment: ""), path)
        case .couldNotAssemble(let path):
            return String(format: NSLocalizedString("模型分段无法合并：%@", tableName: "Yihu", comment: ""), path)
        }
    }
}
