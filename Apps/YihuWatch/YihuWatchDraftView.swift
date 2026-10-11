import Foundation
import SwiftUI
import WatchConnectivity

struct YihuWatchDraftView: View {
    let item: YihuWatchSnapshot.Item
    @State private var text = ""
    @State private var requestID = UUID()
    @State private var busy = false
    @State private var frozen = false
    @State private var blocked = false
    @State private var confirming = false
    @State private var discarding = false
    @State private var notice: String?

    private var file: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("watch-proposal.json")
    }
    private func record() -> YihuWatchDraft? {
        guard let source = item.sourceToken, let target = item.taskToken else { return nil }
        let draft = YihuWatchDraft(requestID: requestID, workbench: item.workbench, task: item.task,
                                   sourceToken: source, taskToken: target, text: text, transferAttempted: frozen)
        guard let data = try? JSONEncoder().encode(draft), (try? YihuWatchDraft.decode(data)) != nil else { return nil }
        return draft
    }
    private func save() -> Bool {
        guard let draft = record() else { notice = "草稿为空、过长或版本不支持"; return false }
        do {
            if FileManager.default.fileExists(atPath: file.path) {
                let handle = try FileHandle(forReadingFrom: file); defer { try? handle.close() }
                let bytes = try handle.read(upToCount: YihuWatchDraft.maximumBytes + 1) ?? Data()
                let prior = try YihuWatchDraft.decode(bytes)
                guard prior.requestID == draft.requestID, prior.workbench == draft.workbench,
                      prior.task == draft.task, prior.sourceToken == draft.sourceToken,
                      prior.taskToken == draft.taskToken,
                      prior.transferAttempted == false || prior.text == draft.text else {
                    blocked = true; notice = "已有另一份草稿或待核内容，原记录保留"; return false
                }
            }
            let directory = file.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            var excluded = directory; var values = URLResourceValues(); values.isExcludedFromBackup = true
            try excluded.setResourceValues(values)
            try JSONEncoder().encode(draft).write(to: file, options: [.atomic, .completeFileProtection])
            return true
        } catch { notice = "草稿未能安全保存，尚未传输"; return false }
    }
    private func transfer() {
        guard !busy, !blocked, save(), let draft = record(), let data = try? JSONEncoder().encode(draft) else { return }
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
                case "saved": notice = "手机草稿已保存；请在手机编辑并二次确认。未提交台账"
                case "changed": notice = "事项或来源已变化，草稿保留；请在手机核对"
                case "busy": notice = "手机正在处理其他内容，草稿保留；请结束后重试"
                default: notice = "手机保存结果待核，原草稿及编号保留；可重试传输"
                }
            }
        }, errorHandler: { _ in
            Task { @MainActor in
                busy = false
                notice = "传输结果待核，草稿及编号保留；重试不会覆盖其他手机草稿"
            }
        })
    }

    var body: some View {
        List {
            Text(item.title).font(.headline)
            Text(item.status)
            TextField("语音或文字草稿", text: $text).disabled(busy || frozen || blocked)
            Text("系统输入可使用听写；最多4000字符，不自动发送意见").font(.footnote)
            if let notice { Text(notice).font(.footnote).foregroundStyle(.orange) }
            Button(frozen ? "核实／重试传到手机" : "确认转为手机草稿") { confirming = true }
                .disabled(busy || blocked || record() == nil)
            if !frozen {
                Button("保存草稿") { _ = save() }.disabled(busy || blocked)
            }
            Button("清除手表草稿副本", role: .destructive) { discarding = true }.disabled(busy)
            Text("断连时先保存草稿；传输过的输入锁定，避免同编号不同内容").font(.footnote).foregroundStyle(.secondary)
        }
        .navigationTitle("输入草稿")
        .task {
            guard FileManager.default.fileExists(atPath: file.path) else { return }
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
                notice = "已恢复草稿，可用原编号核实／重试传输"
            } catch { blocked = true; notice = "原草稿无法读取，记录已保留" }
        }
        .onDisappear { if !blocked && !busy && record() != nil { _ = save() } }
        .alert("清除手表副本？", isPresented: $discarding) {
            Button("取消", role: .cancel) {}
            Button("清除副本", role: .destructive) {
                do {
                    if FileManager.default.fileExists(atPath: file.path) { try FileManager.default.removeItem(at: file) }
                    text = ""; requestID = UUID(); blocked = false; frozen = false
                    notice = "手表副本已清除；不会撤回手机草稿，请先在手机核对"
                } catch { notice = "副本未能清除，原记录保留" }
            }
        } message: { Text("不会撤回已传到手机的草稿。结果待核时请先在手机核对，避免误写第二份意见。") }
        .sheet(isPresented: $confirming) {
            List {
                Text(item.title)
                Text(item.status)
                Text(item.next)
                Text(text)
                Text("只保存到手机草稿；台账发送须在手机再次确认").font(.footnote)
                Button("确认传输草稿") { confirming = false; transfer() }
                Button("取消") { confirming = false }
            }
        }
    }
}
