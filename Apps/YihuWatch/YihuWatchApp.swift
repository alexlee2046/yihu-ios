import Foundation
import Observation
import SwiftUI
import WatchConnectivity
import WidgetKit

func watchText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

private struct YihuWatchVoiceCallback: @unchecked Sendable { var send: ([String: Any]) -> Void }

@MainActor
@Observable
final class YihuWatchLink: NSObject, WCSessionDelegate {
    var snapshot: YihuWatchSnapshot?
    var isDemoSnapshot = false
    var connected = false
    var notice: String?
    let voice = YihuWatchVoiceCapture()

    static func makeDemoSnapshot() -> YihuWatchSnapshot {
        .init(items: [
            .init(workbench: "11111111-1111-1111-1111-111111111111", task: "demo-decision", sourceToken: String(repeating: "0", count: 64),
                  taskToken: String(repeating: "0", count: 64), canDraft: true,
                  title: watchText("确认下一阶段范围"), project: watchText("示例项目"), status: "等你决策", priority: "P1",
                  next: watchText("在手机查看原条目后确认"), sourceDate: Date(), readFailed: false),
            .init(workbench: "11111111-1111-1111-1111-111111111111", task: "demo-acceptance", sourceToken: String(repeating: "0", count: 64),
                  taskToken: String(repeating: "1", count: 64), canDraft: true,
                  title: watchText("验收管理视图"), project: watchText("示例项目"), status: "等你验收", priority: "P1",
                  next: watchText("核对清单并在手机反馈"), sourceDate: Date().addingTimeInterval(-3600), readFailed: false)
        ], capturedAt: Date(), truncated: false, hasSource: true, sourceDate: Date(), decisionCount: 1, acceptanceCount: 1)
    }

    func loadDemoSnapshot() {
        isDemoSnapshot = true
        snapshot = Self.makeDemoSnapshot()
        notice = watchText("已加载示例事项，可体验草稿与录音")
    }

    func clearDemoSnapshot() {
        isDemoSnapshot = false
        snapshot = nil
        notice = nil
    }

    override init() {
        super.init()
        snapshot = Self.makeDemoSnapshot()
        isDemoSnapshot = true
        #if DEBUG
        if ProcessInfo.processInfo.environment["YIHU_WATCH_DEMO"] == "1" {
            return
        }
        #endif
        voice.restore()
        guard WCSession.isSupported() else { notice = watchText("此设备不支持手机接续"); return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func receive(_ data: Data?) {
        connected = WCSession.default.isReachable
        guard let data else { return }
        do {
            let value = try YihuWatchSnapshot.decode(data)
            isDemoSnapshot = false
            snapshot = value
            do {
                try YihuWatchWidgetStore.save(.init(value), to: YihuWatchWidgetStore.file)
                WidgetCenter.shared.reloadTimelines(ofKind: YihuWatchWidgetStore.kind)
            } catch { notice = watchText("列表已同步；表盘数据暂未保存，请检查共享容器配置") }
        } catch { notice = watchText("手机数据无法读取，保留上次数据") }
    }

    func request(_ item: YihuWatchSnapshot.Item? = nil) {
        guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
            notice = watchText("请连接并解锁手机，打开一呼后重试"); return
        }
        var message: [String: String] = ["kind": "sync"]
        if let item {
            guard let token = item.sourceToken else { notice = watchText("请先在手机刷新并重新同步"); return }
            message = ["kind": "open", "workbench": item.workbench, "task": item.task, "sourceToken": token]
        }
        let opening = item != nil
        WCSession.default.sendMessage(message, replyHandler: { [weak self] response in
            let queued = response["queued"] as? Bool == true
            Task { @MainActor [weak self] in
                self?.notice = queued ? (opening ? watchText("已请求手机接续，请解锁并打开一呼") : watchText("已请求同步手机数据")) : watchText("请在手机继续操作")
            }
        }, errorHandler: { [weak self] _ in
            Task { @MainActor [weak self] in self?.notice = watchText("手机暂不可达，请稍后重试") }
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
    @State private var route: YihuWatchRoute = .all
    @State private var navigationID = UUID()
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
        case "enabled": watchText("手机通知已开启")
        case "denied": watchText("手机系统通知未授权")
        case "unsupported": watchText("当前手机服务不支持原生通知")
        case "disabled": watchText("手机通知未开启")
        default: watchText("请在手机检查通知设置")
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
                            Label(link.connected ? watchText("手机可达") : watchText("手机暂未连接"), systemImage: link.connected ? "iphone" : "iphone.slash")
                                .foregroundStyle(link.connected ? Color.secondary : Color.orange)
                            if let notice = link.notice { Text(notice).font(.footnote) }
                            NavigationLink(watchText("未完成草稿／录音")) { YihuWatchRecoveryView(link: link) }
                            if route != .all { Button(watchText("查看全部待处理")) { route = .all } }
                            Button(watchText("同步手机已有数据")) { link.request() }
                            if link.snapshot == nil {
                                Button(watchText("加载示例事项")) { link.loadDemoSnapshot() }
                            } else if link.isDemoSnapshot {
                                Button(watchText("退出示例事项")) { link.clearDemoSnapshot() }
                            }
                            NavigationLink(watchText("通知状态与镜像")) {
                                List {
                                    Text(notificationTitle)
                                    Text(watchText("可在 iPhone 的 Watch App → 通知中开启一呼通知镜像")).font(.footnote).foregroundStyle(.secondary)
                                }.navigationTitle(watchText("通知"))
                            }
                        }
                        if let snapshot = link.snapshot {
                            if !snapshot.hasSource { Text(watchText("请先在手机配置或刷新需求台账")) }
                            else if snapshot.stale { Text(watchText("数据过期或读取失败，请在手机刷新")).foregroundStyle(.orange) }
                            if snapshot.incompleteSources == true {
                                Text(watchText("部分来源刷新未完成")).font(.footnote).foregroundStyle(.orange)
                            }
                            ForEach(route.status.map { [$0] } ?? ["等你决策", "等你验收"], id: \.self) { status in
                                let items = snapshot.items.filter { $0.status == status }
                                let localizedStatus = watchText(status)
                                Section(snapshot.count(for: status).map { "\(localizedStatus) · \($0)" } ?? localizedStatus) {
                                    if items.isEmpty {
                                        Text(snapshot.truncated ? watchText("当前传输未包含此类事项，请在手机查看") : watchText("当前快照暂无事项")).foregroundStyle(.secondary)
                                    }
                                    ForEach(items) { item in
                                        NavigationLink {
                                            List {
                                                Text(watchText(item.title)).font(.headline)
                                                Text(watchText(item.project) + " · " + watchText(item.status))
                                                if !item.priority.isEmpty { Text(item.priority) }
                                                if !item.next.isEmpty { Text(watchText(item.next)) }
                                                if let date = item.sourceDate { Text(date, style: .date); Text(date, style: .time) }
                                                if item.stale { Label(watchText("数据过期或读取失败，请在手机刷新"), systemImage: "clock.badge.exclamationmark").foregroundStyle(.orange) }
                                                Button(watchText("转手机继续处理")) { link.request(item) }
                                                if item.canDraft == true, item.taskToken != nil {
                                                    NavigationLink(watchText("语音／文字草稿")) { YihuWatchDraftView(item: item, link: link) }
                                                } else {
                                                    Text(watchText("草稿传输不可用；请在手机检查数据源并刷新，再同步到手表"))
                                                        .font(.footnote).foregroundStyle(.secondary)
                                                }
                                                if let notice = link.notice { Text(notice).font(.footnote) }
                                            }.navigationTitle(watchText("事项详情"))
                                        } label: {
                                            VStack(alignment: .leading) {
                                                Text(watchText(item.title))
                                                Text(watchText(item.project)).font(.caption).foregroundStyle(.secondary)
                                                if item.stale { Text(watchText("数据待刷新")).font(.caption).foregroundStyle(.orange) }
                                            }
                                        }
                                    }
                                }
                            }
                            if snapshot.truncated { Text(watchText("更多事项请在手机查看")).font(.footnote) }
                        } else {
                            Text(watchText("暂无手机数据；请在已配对手机打开一呼并刷新台账")).font(.footnote)
                        }
                    }
                }.navigationTitle(route.status.map(watchText) ?? watchText("一呼"))
                }
            }
            .id(navigationID)
            .onOpenURL { url in
                guard let destination = YihuWatchRoute(url: url) else { return }
                // An explicit widget tap returns to its category, even from a warm detail screen.
                // The shared voice object and durably saved drafts outlive this navigation stack.
                link.voice.stop(send: false)
                route = destination
                navigationID = UUID()
            }
        }
    }
}
