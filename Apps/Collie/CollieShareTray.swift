import Observation
import Foundation
import SwiftUI

private func shareText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

/// Shared items waiting to be inserted into the current workbench. Text and
/// links go into the focused input; files go through the page's own upload
/// control. Nothing is ever sent; a batch leaves the inbox only when fully placed.
@MainActor
@Observable
final class CollieShareTrayModel {
    static let shared = CollieShareTrayModel()

    private(set) var batches: [CollieShareBatch] = []
    private(set) var notice: String?
    private(set) var isInserting = false
    private let inbox: CollieShareInbox?

    init(inbox: CollieShareInbox? = CollieShareInbox.shared()) {
        self.inbox = inbox
    }

    var itemCount: Int { batches.reduce(0) { $0 + $1.items.count } }

    func refresh() {
        inbox?.sweepIncomplete()
        batches = inbox?.pending() ?? []
        if batches.isEmpty { notice = nil }
    }

    /// "Open in 一呼" from another app: copy the file into the inbox.
    func importOpened(_ url: URL) {
        guard url.isFileURL, let inbox else { return }
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            _ = try inbox.save(texts: [], urls: [], files: [url])
            notice = nil
        } catch {
            notice = error.localizedDescription
        }
        // iOS delivered a private copy into Documents/Inbox; the inbox now owns its own copy.
        if url.path.contains("/Documents/Inbox/") { try? FileManager.default.removeItem(at: url) }
        refresh()
    }

    func discardAll() {
        batches.forEach { inbox?.remove($0) }
        refresh()
    }

    func insertAll(into session: CollieWebSession) async {
        guard let inbox, !isInserting else { return }
        isInserting = true
        defer { isInserting = false }
        for var batch in batches {
            // Files first: once attached they leave the batch, so a retry never repeats them;
            // text goes last, so a failed attach never leaves already-inserted text behind.
            let files = batch.items.compactMap { item -> CollieWebSession.SharedFile? in
                guard let url = inbox.fileURL(for: item, in: batch), let name = item.fileName else { return nil }
                return CollieWebSession.SharedFile(url: url, name: name, contentType: item.contentType)
            }
            if !files.isEmpty {
                switch await session.attachFiles(files) {
                case .attached:
                    for item in batch.items where item.kind == .file {
                        if let url = inbox.fileURL(for: item, in: batch) { try? FileManager.default.removeItem(at: url) }
                    }
                    batch.items.removeAll { $0.kind == .file }
                    if batch.items.isEmpty { inbox.remove(batch) } else { try? inbox.update(batch) }
                case .noUploadControl:
                    notice = shareText("当前工作台页面没有能接收这类文件的上传入口，文件先留在一呼里。")
                    refresh()
                    return
                case .oneAtATime:
                    notice = shareText("这个页面一次只能上传一个文件，请逐个分享。")
                    refresh()
                    return
                case .failed:
                    notice = shareText("文件没能交给工作台，请重试。")
                    refresh()
                    return
                }
            }
            let texts = batch.items.filter { $0.kind != .file }.compactMap(\.text)
            if !texts.isEmpty {
                guard await session.insertTranscript(texts.joined(separator: "\n")) else {
                    notice = shareText("请先点一下工作台的输入框，再点「填入」。")
                    refresh()
                    return
                }
            }
            inbox.remove(batch)
        }
        notice = nil
        refresh()
    }
}

struct CollieShareTray: View {
    let model: CollieShareTrayModel
    let session: CollieWebSession

    var body: some View {
        if model.itemCount > 0 {
            VStack(alignment: .leading, spacing: 8) {
                Label(String(format: shareText("收到分享 · %lld 项"), Int64(model.itemCount)), systemImage: "tray.and.arrow.down.fill")
                    .font(.subheadline.weight(.semibold))
                Text(model.batches.flatMap(\.items).map(\.displayName).prefix(3).joined(separator: shareText("、")))
                    .font(.caption)
                    .foregroundStyle(BenchsideStyle.secondary)
                    .lineLimit(2)
                if let notice = model.notice {
                    Text(notice)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 10) {
                    Button {
                        Task { await model.insertAll(into: session) }
                    } label: {
                        Text(model.isInserting ? shareText("正在填入…") : shareText("填入当前工作台"))
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.isInserting || !session.isConnected)
                    .accessibilityIdentifier("collie-share-insert")
                    Button(shareText("清除")) { model.discardAll() }
                        .buttonStyle(.bordered)
                        .disabled(model.isInserting)
                        .accessibilityIdentifier("collie-share-discard")
                }
                .controlSize(.large)
            }
            .padding(14)
            .background(BenchsideStyle.surfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BenchsideStyle.border, lineWidth: 1) }
            .shadow(color: .black.opacity(0.12), radius: 14, y: 5)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .tint(BenchsideStyle.accent)
        }
    }
}
