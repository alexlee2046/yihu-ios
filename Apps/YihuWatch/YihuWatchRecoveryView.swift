import SwiftUI

/// Always reachable, independent of the current phone snapshot or task eligibility.
struct YihuWatchRecoveryView: View {
    let link: YihuWatchLink
    @Environment(\.scenePhase) private var scenePhase
    @State private var draft: YihuWatchDraft?
    @State private var unreadable = false
    @State private var notice: String?
    @State private var clearingDraft = false
    @State private var clearingAudio = false
    private let drafts = YihuWatchDraftStore.local

    private func reload() {
        do { draft = try drafts.load(); unreadable = false }
        catch { draft = nil; unreadable = true }
        link.voice.restore()
    }
    private var draftItem: YihuWatchSnapshot.Item? {
        guard let draft else { return nil }
        return link.snapshot?.items.first { draft.matches($0) && $0.canDraft == true }
    }
    private var voiceItem: YihuWatchSnapshot.Item? {
        guard link.voice.pending != nil, !link.voice.blocked else { return nil }
        return link.snapshot?.items.first { link.voice.matches($0) && $0.canDraft == true }
    }
    var body: some View {
        List {
            Text("这里保留的是手表副本；已交手机不等于已提交台账。")
                .font(.footnote).foregroundStyle(.secondary)
            Section("文字草稿") {
                if let draft {
                    Text(draft.title ?? "原事项草稿").font(.headline)
                    Text(draft.phoneSaved == true ? "已交手机 · 未提交台账" :
                         draft.transferAttempted != false ? "传输结果待核" : "仅保存在手表")
                        .font(.footnote)
                    Text(draft.text)
                    if let item = draftItem {
                        NavigationLink("查看／继续原草稿") { YihuWatchDraftView(item: item, link: link) }
                    } else {
                        Text("原事项已变化、未同步或不在当前列表；仅供核对，不会转给其他事项。")
                            .font(.footnote).foregroundStyle(.orange)
                    }
                } else if unreadable {
                    Text("原草稿暂不可读，文件仍保留。解锁后重试；清除将永久移除手表副本。")
                        .font(.footnote).foregroundStyle(.orange)
                } else { Text("暂无本地草稿").foregroundStyle(.secondary) }
                if draft != nil || unreadable {
                    Button("清除手表草稿副本", role: .destructive) { clearingDraft = true }
                        .disabled(link.voice.recording || link.voice.sending)
                }
            }
            Section("录音／识别结果") {
                if link.voice.hasAudio {
                    if let result = link.voice.result { Text(result.text) }
                    if let item = voiceItem {
                        Text(item.title)
                        NavigationLink("继续原事项录音") { YihuWatchDraftView(item: item, link: link) }
                    } else {
                        Text("原录音仍保留；原事项未同步、已变化或记录不可读时，不会改绑到新事项。")
                            .font(.footnote).foregroundStyle(.orange)
                    }
                    Button("核对后丢弃录音副本", role: .destructive) { clearingAudio = true }
                        .disabled(link.voice.recording || link.voice.sending)
                } else { Text("暂无本地录音").foregroundStyle(.secondary) }
                if let message = link.voice.notice { Text(message).font(.footnote) }
            }
            Button("重新读取本地副本") { reload() }
            Button("同步手机已有数据") { link.request() }
            if let message = link.notice { Text(message).font(.footnote) }
            if let notice { Text(notice).font(.footnote) }
        }
        .navigationTitle("未完成内容")
        .onAppear { reload() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { reload() } }
        .alert("清除这份手表草稿？", isPresented: $clearingDraft) {
            Button("取消", role: .cancel) {}
            Button("清除副本", role: .destructive) {
                do { try drafts.clear(); reload(); notice = "手表副本已清除；不会撤回手机内容" }
                catch { notice = "未能清除，原副本保留" }
            }
        } message: { Text("请先核对手机。此操作不可撤销，不会撤回已传输的内容；未传输的草稿将丢失。") }
        .alert("丢弃这份录音副本？", isPresented: $clearingAudio) {
            Button("取消", role: .cancel) {}
            Button("丢弃副本", role: .destructive) {
                if link.voice.blocked { link.voice.clearUnreadableCopy() }
                else { link.voice.discard() }
            }
        } message: {
            Text(link.voice.blocked ? "记录不可读，无法核实手机；请先自行核对。将永久删除手表录音，不撤回手机内容。" : "先连接手机核对识别状态，成功后才清除手表副本；不撤回已有文字。")
        }
    }
}
