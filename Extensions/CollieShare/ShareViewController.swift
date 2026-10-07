import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// "Share → 一呼": copies whatever was shared (text, links, files, photos,
/// video, audio) into the App Group inbox. The app later inserts it into the
/// current workbench on the user's tap; nothing is sent from here.
final class ShareViewController: UIViewController {
    private let model = ShareModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: ShareView(model: model) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        } cancel: { [weak self] in
            self?.model.discardStaging()
            self?.extensionContext?.cancelRequest(withError: CocoaError(.userCancelled))
        })
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
            .flatMap { $0.attachments ?? [] }
        Task { await model.load(providers) }
    }
}

@MainActor
@Observable
final class ShareModel {
    enum State: Equatable { case loading, ready, saving, saved, failed(String) }

    var state: State = .loading
    var summary: [String] = []
    private var texts: [String] = []
    private var urls: [URL] = []
    private var files: [URL] = []
    private let staging = FileManager.default.temporaryDirectory
        .appendingPathComponent("collie-share-\(UUID().uuidString)", isDirectory: true)

    func load(_ providers: [NSItemProvider]) async {
        try? FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
        for provider in providers {
            if let url = await Self.webURL(provider) {
                urls.append(url)
                summary.append(String(format: NSLocalizedString("链接：%@", tableName: "Yihu", comment: ""), url.host() ?? url.absoluteString))
            } else if let file = await Self.file(provider, into: staging) {
                files.append(file)
                summary.append(String(format: NSLocalizedString("文件：%@", tableName: "Yihu", comment: ""), file.lastPathComponent))
            } else if let text = await Self.text(provider) {
                texts.append(text)
                summary.append(String(format: NSLocalizedString("文字：%@", tableName: "Yihu", comment: ""), String(text.prefix(30))))
            }
        }
        state = summary.isEmpty ? .failed(NSLocalizedString("没有可以转给一呼的内容。", tableName: "Yihu", comment: "")) : .ready
    }

    func save() {
        state = .saving
        let (texts, urls, files) = (texts, urls, files)
        Task {
            // Copying large videos must not block the share sheet's main thread.
            let result = await Task.detached(priority: .userInitiated) { () -> String? in
                do {
                    guard let inbox = CollieShareInbox.shared() else { throw CollieShareInboxError.unavailable }
                    _ = try inbox.save(texts: texts, urls: urls, files: files)
                    return nil
                } catch {
                    return error.localizedDescription
                }
            }.value
            discardStaging()
            state = result.map { .failed($0) } ?? .saved
        }
    }

    func discardStaging() {
        try? FileManager.default.removeItem(at: staging)
    }

    private static func webURL(_ provider: NSItemProvider) async -> URL? {
        guard provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
              !provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        else { return nil }
        let item = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier)
        guard let url = item as? URL, let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else { return nil }
        return url
    }

    private static func text(_ provider: NSItemProvider) async -> String? {
        guard provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) else { return nil }
        return try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) as? String
    }

    /// Any concrete file-like representation (photo, video, audio, document…).
    private static func file(_ provider: NSItemProvider, into directory: URL) async -> URL? {
        let candidates = provider.registeredTypeIdentifiers.filter { identifier in
            guard let type = UTType(identifier) else { return false }
            return !type.conforms(to: .plainText) && !type.conforms(to: .url)
                && (type.conforms(to: .data) || type.conforms(to: .package))
        }
        guard let identifier = candidates.first else { return nil }
        return await withCheckedContinuation { continuation in
            _ = provider.loadFileRepresentation(forTypeIdentifier: identifier) { url, _ in
                // The provided file only exists inside this callback: copy it out now.
                guard let url else { continuation.resume(returning: nil); return }
                var name = provider.suggestedName ?? url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension.isEmpty
                    ? (UTType(identifier)?.preferredFilenameExtension ?? "") : url.pathExtension
                if !ext.isEmpty, (name as NSString).pathExtension.isEmpty { name += ".\(ext)" }
                let destination = directory.appendingPathComponent(UUID().uuidString, isDirectory: true)
                    .appendingPathComponent(name)
                do {
                    try FileManager.default.createDirectory(
                        at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try FileManager.default.copyItem(at: url, to: destination)
                    continuation.resume(returning: destination)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

struct ShareView: View {
    let model: ShareModel
    let done: () -> Void
    let cancel: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(model.summary, id: \.self) { line in
                        Text(line).lineLimit(2)
                    }
                    if model.state == .loading { ProgressView() }
                } footer: {
                    Text(footer)
                }
            }
            .navigationTitle(NSLocalizedString("发到一呼", tableName: "Yihu", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("取消", tableName: "Yihu", comment: ""), action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(model.state == .saved ? NSLocalizedString("完成", tableName: "Yihu", comment: "") : NSLocalizedString("放入一呼", tableName: "Yihu", comment: "")) {
                        if model.state == .saved { done() } else { model.save() }
                    }
                    .disabled(model.state != .ready && model.state != .saved)
                }
            }
        }
        .onChange(of: model.state) { _, state in
            guard state == .saved else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.2))
                done()
            }
        }
    }

    private var footer: String {
        switch model.state {
        case .loading: return NSLocalizedString("正在读取分享内容…", tableName: "Yihu", comment: "")
        case .ready: return NSLocalizedString("放入后，打开一呼点「填入当前工作台」。不会自动发送。", tableName: "Yihu", comment: "")
        case .saving: return NSLocalizedString("正在保存…", tableName: "Yihu", comment: "")
        case .saved: return NSLocalizedString("已放入一呼。打开一呼即可填入当前工作台。", tableName: "Yihu", comment: "")
        case .failed(let message): return message
        }
    }
}
