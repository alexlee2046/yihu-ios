import Foundation
import Observation
import SwiftUI
import WatchConnectivity

private struct YihuWatchVoiceCallback: @unchecked Sendable { var send: ([String: Any]) -> Void }

@MainActor
@Observable
final class YihuWatchLink: NSObject, WCSessionDelegate {
    var snapshot: YihuWatchSnapshot?
    var connected = false
    var notice: String?
    let voice = YihuWatchVoiceCapture()

    override init() {
        super.init()
        #if DEBUG
        if ProcessInfo.processInfo.environment["YIHU_WATCH_DEMO"] == "1" {
            snapshot = .init(items: [
                .init(workbench: "11111111-1111-1111-1111-111111111111", task: "demo-decision", sourceToken: String(repeating: "0", count: 64),
                      taskToken: String(repeating: "0", count: 64), canDraft: true,
                      title: "确认下一阶段范围", project: "示例项目", status: "等你决策", priority: "P1",
                      next: "在手机查看原条目后确认", sourceDate: Date(), readFailed: false),
                .init(workbench: "11111111-1111-1111-1111-111111111111", task: "demo-acceptance", sourceToken: String(repeating: "0", count: 64),
                      title: "验收管理视图", project: "示例项目", status: "等你验收", priority: "P1",
                      next: "核对清单并在手机反馈", sourceDate: Date().addingTimeInterval(-90000), readFailed: false)
            ], capturedAt: Date(), truncated: false, hasSource: true, sourceDate: Date())
            notice = "模拟数据 · 不代表配对验证"
            return
        }
        #endif
        guard WCSession.isSupported() else { notice = "此设备不支持手机接续"; return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func receive(_ data: Data?) {
        connected = WCSession.default.isReachable
        guard let data else { return }
        do { snapshot = try YihuWatchSnapshot.decode(data) }
        catch { notice = "手机数据无法读取，保留上次数据" }
    }

    func request(_ item: YihuWatchSnapshot.Item? = nil) {
        guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
            notice = "请连接并解锁手机，打开一呼后重试"; return
        }
        var message: [String: String] = ["kind": "sync"]
        if let item {
            guard let token = item.sourceToken else { notice = "手机数据版本较旧，请更新并重新同步；仅可查看"; return }
            message = ["kind": "open", "workbench": item.workbench, "task": item.task, "sourceToken": token]
        }
        let opening = item != nil
        WCSession.default.sendMessage(message, replyHandler: { [weak self] response in
            let queued = response["queued"] as? Bool == true
            Task { @MainActor [weak self] in
                self?.notice = queued ? (opening ? "已请求手机接续，请解锁并打开一呼" : "已请求手机发送已有数据；刷新台账请在手机操作") : "手机未接受请求，请在手机继续"
            }
        }, errorHandler: { [weak self] _ in
            Task { @MainActor [weak self] in self?.notice = "手机暂不可达，请稍后重试" }
        })
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let data = session.receivedApplicationContext["radar"] as? Data
        Task { @MainActor [weak self] in self?.receive(data) }
    }
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let reachable = session.isReachable
        Task { @MainActor [weak self] in self?.connected = reachable }
    }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard message["kind"] as? String == "voiceResult", let data = message["result"] as? Data else {
            replyHandler(["stored": false]); return
        }
        let callback = YihuWatchVoiceCallback(send: replyHandler)
        Task { @MainActor [weak self] in callback.send(["stored": self?.voice.receive(data) ?? false]) }
    }
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard userInfo["kind"] as? String == "voiceResult", let data = userInfo["result"] as? Data else { return }
        Task { @MainActor [weak self] in _ = self?.voice.receive(data) }
    }
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let data = applicationContext["radar"] as? Data
        Task { @MainActor [weak self] in self?.receive(data) }
    }
}

@main
struct YihuWatchApp: App {
    @State private var link = YihuWatchLink()
    private var demoDraftItem: YihuWatchSnapshot.Item? {
        #if DEBUG
        if ProcessInfo.processInfo.environment["YIHU_WATCH_DEMO_PAGE"] == "draft" ||
           ProcessInfo.processInfo.arguments.contains("--watch-draft-demo") {
            return link.snapshot?.items.first
        }
        #endif
        return nil
    }
    private var notificationTitle: String {
        switch link.snapshot?.phoneNotificationState {
        case "enabled": "手机通知已开启；手表镜像需本人设置"
        case "denied": "手机系统通知未授权"
        case "unsupported": "当前手机服务不支持原生通知"
        case "disabled": "手机通知未开启"
        default: "手机通知能力未核实，请在手机检查"
        }
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let item = demoDraftItem {
                    YihuWatchDraftView(item: item, link: link)
                } else {
                TimelineView(.periodic(from: .now, by: 60)) { _ in
                    List {
                        Section {
                            Label(link.connected ? "手机可达" : "手机暂未连接", systemImage: link.connected ? "iphone" : "iphone.slash")
                                .foregroundStyle(link.connected ? Color.secondary : Color.orange)
                            if let notice = link.notice { Text(notice).font(.footnote) }
                            Button("同步手机已有数据") { link.request() }
                            NavigationLink("通知状态与镜像") {
                                List {
                                    Text(notificationTitle)
                                    Text("如手机已有通知可用，请在 iPhone 的 Watch App → 通知开启一呼镜像").font(.footnote)
                                    Text("镜像需手机锁定、手表佩戴解锁及系统设置允许；是否送达以实机为准").font(.footnote)
                                    Text("待决策／验收台账当前仅按手机刷新读取，未连接推送事件；不会用轮询伪装通知").font(.footnote)
                                    Text("系统镜像的工作台通知仍走手机原权限与接续保护；没有手表独立推送或自动回复").font(.footnote)
                                }.navigationTitle("通知")
                            }
                        }
                        if let snapshot = link.snapshot {
                            if !snapshot.hasSource { Text("请先在手机配置或刷新需求台账") }
                            else if snapshot.stale { Text("数据过期或读取失败，请在手机刷新").foregroundStyle(.orange) }
                            ForEach(["等你决策", "等你验收"], id: \.self) { status in
                                let items = snapshot.items.filter { $0.status == status }
                                Section(status + " · " + String(items.count)) {
                                    if items.isEmpty { Text("暂无事项").foregroundStyle(.secondary) }
                                    ForEach(items) { item in
                                        NavigationLink {
                                            List {
                                                Text(item.title).font(.headline)
                                                Text(item.project + " · " + item.status)
                                                if !item.priority.isEmpty { Text(item.priority) }
                                                Text(item.next.isEmpty ? "下一步待补" : item.next)
                                                if let date = item.sourceDate { Text(date, style: .date); Text(date, style: .time) }
                                                if item.stale { Label("数据过期或读取失败，请在手机刷新", systemImage: "clock.badge.exclamationmark").foregroundStyle(.orange) }
                                                Button("转手机继续处理") { link.request(item) }
                                                if item.canDraft == true, item.taskToken != nil {
                                                    NavigationLink("语音／文字草稿") { YihuWatchDraftView(item: item, link: link) }
                                                } else {
                                                    Text("草稿传输不可用；请在手机检查数据源并刷新，再同步到手表")
                                                        .font(.footnote).foregroundStyle(.secondary)
                                                }
                                                if let notice = link.notice { Text(notice).font(.footnote) }
                                                Text("手表不提交回复或改变状态；草稿仅传到手机").font(.footnote).foregroundStyle(.secondary)
                                            }.navigationTitle("事项详情")
                                        } label: {
                                            VStack(alignment: .leading) {
                                                Text(item.title)
                                                Text(item.project).font(.caption).foregroundStyle(.secondary)
                                                if item.stale { Text("数据待刷新").font(.caption).foregroundStyle(.orange) }
                                            }
                                        }
                                    }
                                }
                            }
                            if snapshot.truncated { Text("更多事项请在手机查看").font(.footnote) }
                        } else {
                            Text("暂无手机数据；请在已配对手机打开一呼并刷新台账").font(.footnote)
                        }
                    }
                }.navigationTitle("一呼")
                }
            }
        }
    }
}
