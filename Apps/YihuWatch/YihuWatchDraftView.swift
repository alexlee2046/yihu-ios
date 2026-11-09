import Foundation
import SwiftUI
import WatchConnectivity

struct YihuWatchDraftView: View {
    let item: YihuWatchSnapshot.Item
    let link: YihuWatchLink
    @Environment(\.scenePhase) private var scenePhase
    @State private var discardingAudio = false
    private var voice: YihuWatchVoiceCapture { link.voice }
    @State private var text = ""
    @State private var requestID = UUID()
    @State private var busy = false
    @State private var frozen = false
    @State private var phoneSaved = false
    @State private var blocked = false
    @State private var confirming = false
    @State private var discarding = false
    @State private var notice: String?

    private let drafts = YihuWatchDraftStore.local
    private var file: URL { drafts.file }
    private var inputLocked: Bool {
        busy || frozen || blocked || voice.recording || voice.hasAudio || voice.sending
    }
    private func record() -> YihuWatchDraft? {
        guard let source = item.sourceToken, let target = item.taskToken else { return nil }
        let draft = YihuWatchDraft(requestID: requestID, workbench: item.workbench, task: item.task,
                                   sourceToken: source, taskToken: target, text: text, transferAttempted: frozen,
                                   phoneSaved: phoneSaved, title: String(item.title.prefix(160)))
        guard let data = try? JSONEncoder().encode(draft), (try? YihuWatchDraft.decode(data)) != nil else { return nil }
        return draft
    }
    private func save() -> Bool {
        guard let draft = record() else { notice = "草稿为空、过长或版本不支持"; return false }
        do {
            try drafts.save(draft)
            return true
        } catch { notice = "草稿未能安全保存，尚未传输"; return false }
    }
    private func transfer() {
        guard !busy, !blocked, !phoneSaved, save(), let draft = record(), let data = try? JSONEncoder().encode(draft) else { return }
        guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
            notice = "手机未连接，草稿已保留；打开手机一呼后重试"; return
        }
        frozen = true
        guard save() else { frozen = false; return }
        busy = true
        WCSession.default.sendMessage(["kind": "draft", "draft": data], replyHandler: { response in
            let state = response["state"] as? String ?? "unavailable"
            Task { @MainActor in
                busy = false
                switch state {
                case "saved":
                    phoneSaved = true
                    if save() { notice = "手机草稿已保存；请在手机继续确认" }
                    else { notice = "手机已确认保存，但手表回执未能落盘；请在手机核对" }
                case "changed": notice = "事项或来源已变化，草稿保留；请在手机核对"
                case "busy": notice = "手机正在处理其他内容，草稿保留；请结束后重试"
                default: notice = "手机保存结果待核，原草稿及编号保留；可重试传输"
                }
            }
        }, errorHandler: { _ in
            Task { @MainActor in
                busy = false
                notice = "传输未确认，草稿已保留，可重试"
            }
        })
    }

    private func applyVoiceResult() {
        guard let result = voice.result, result.outcome == .ready, voice.matches(item),
              result.request.requestID == requestID, !busy, !frozen, !blocked else { return }
        guard text.isEmpty || text == result.text else {
            notice = "草稿已有内容，识别结果已保留"; return
        }
        let previous = text
        text = result.text
        if save() { voice.consumed(); notice = "手机端侧识别已填入手表草稿" }
        else { text = previous }
    }

    var body: some View {
        List {
            Text(item.title).font(.headline)
            Text(item.status)
            if phoneSaved { Label("已同步至手机草稿", systemImage: "checkmark.circle") }
            TextField("语音或文字草稿", text: $text).disabled(inputLocked)
            Section("快捷草稿") {
                ForEach(YihuWatchQuickDraft.templates, id: \.self) { template in
                    Button(template) {
                        guard YihuWatchQuickDraft.canApply(text: text, locked: inputLocked) else { return }
                        text = template
                        if save() { notice = "已填入草稿" }
                    }
                    .disabled(!YihuWatchQuickDraft.canApply(text: text, locked: inputLocked))
                }
            }
            if voice.recording {
                Button("停止并交手机本地识别") { voice.stop(send: true) }
            } else if voice.hasAudio {
                if voice.matches(item), !voice.blocked {
                    Button("核实／重试手机本地识别") { voice.retry() }.disabled(voice.sending || voice.result != nil)
                } else { Text("已有其他事项或旧来源录音，副本已保留").font(.footnote) }
                if voice.pending != nil, !voice.blocked {
                    Button("丢弃录音副本", role: .destructive) { discardingAudio = true }.disabled(voice.sending)
                }
            } else {
                Button("录音，由手机端侧识别") { Task { await voice.start(item, requestID: requestID) } }
                    .disabled(busy || frozen || blocked || voice.sending || !text.isEmpty)
            }
            if let message = voice.notice { Text(message).font(.footnote).foregroundStyle(.orange) }
            if let notice { Text(notice).font(.footnote).foregroundStyle(.orange) }
            if phoneSaved {
                Button("转手机继续确认") { link.request(item) }
            } else {
                Button(frozen ? "核实／重试传到手机" : "确认转为手机草稿") { confirming = true }
                    .disabled(busy || blocked || record() == nil)
            }
            if !frozen {
                Button("保存草稿") { _ = save() }.disabled(busy || blocked)
            }
            Button("清除手表草稿副本", role: .destructive) { discarding = true }
                .disabled(busy || voice.recording || voice.hasAudio || voice.sending)
        }
        .navigationTitle("输入草稿")
        .task {
            voice.foreground = scenePhase == .active
            voice.attach(item)
            if let pending = voice.pending, voice.matches(item) { requestID = pending.requestID }
            guard FileManager.default.fileExists(atPath: file.path) else { applyVoiceResult(); return }
            do {
                let handle = try FileHandle(forReadingFrom: file); defer { try? handle.close() }
                let data = try handle.read(upToCount: YihuWatchDraft.maximumBytes + 1) ?? Data()
                let saved = try YihuWatchDraft.decode(data)
                guard saved.workbench == item.workbench, saved.task == item.task,
                      saved.sourceToken == item.sourceToken, saved.taskToken == item.taskToken else {
                    blocked = true; notice = "有另一事项或旧版本草稿，原记录保留；请先在手机核对"; return
                }
                text = saved.text; requestID = saved.requestID
                frozen = saved.transferAttempted != false
                phoneSaved = saved.phoneSaved == true
                notice = phoneSaved ? "已同步至手机草稿，请在手机继续" : "已恢复草稿，可用原编号核实／重试传输"
            } catch { blocked = true; notice = "原草稿无法读取，记录已保留" }
            applyVoiceResult()
        }
        .onChange(of: voice.result) { _, _ in applyVoiceResult() }
        .onChange(of: text) { _, _ in
            if !blocked && !busy && !frozen && record() != nil { _ = save() }
        }
        .onChange(of: scenePhase) { _, phase in
            voice.foreground = phase == .active
            if phase != .active {
                voice.stop(send: false)
                if !blocked && !busy && record() != nil { _ = save() }
            }
        }
        .onDisappear {
            voice.foreground = false; voice.stop(send: false)
            if !blocked && !busy && record() != nil { _ = save() }
        }
        .alert("丢弃这段录音？", isPresented: $discardingAudio) {
            Button("取消", role: .cancel) {}
            Button("丢弃录音", role: .destructive) { voice.discard() }
        } message: { Text("核对手机后可丢弃手表上的录音副本。") }
        .alert("清除手表副本？", isPresented: $discarding) {
            Button("取消", role: .cancel) {}
            Button("清除副本", role: .destructive) {
                do {
                    try drafts.clear()
                    text = ""; requestID = UUID(); blocked = false; frozen = false; phoneSaved = false
                    notice = "手表草稿已清除"
                } catch { notice = "副本未能清除，原记录保留" }
            }
        } message: { Text("清除手表上的草稿副本，已传到手机的草稿请在手机查看。") }
        .sheet(isPresented: $confirming) {
            List {
                Text(item.title)
                Text(item.status)
                if !item.next.isEmpty { Text(item.next) }
                Text(text)
                Text("保存到手机草稿后可在手机上继续编辑并确认发送").font(.footnote).foregroundStyle(.secondary)
                Button("确认传输草稿") { confirming = false; transfer() }
                Button("取消") { confirming = false }
            }
        }
    }
}
