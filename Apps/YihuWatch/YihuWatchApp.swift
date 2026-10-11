import Foundation
import Observation
import SwiftUI
import WatchConnectivity

@MainActor
@Observable
final class YihuWatchLink: NSObject, WCSessionDelegate {
    var snapshot: YihuWatchSnapshot?
    var connected = false
    var notice: String?

    override init() {
        super.init()
        #if DEBUG
        if ProcessInfo.processInfo.environment["YIHU_WATCH_DEMO"] == "1" {
            snapshot = .init(items: [
                .init(workbench: "11111111-1111-1111-1111-111111111111", task: "demo-decision", sourceToken: String(repeating: "0", count: 64),
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
        if let item { message = ["kind": "open", "workbench": item.workbench, "task": item.task, "sourceToken": item.sourceToken] }
        let opening = item != nil
        WCSession.default.sendMessage(message, replyHandler: { response in
            let queued = response["queued"] as? Bool == true
            Task { @MainActor [weak self] in
                self?.notice = queued ? (opening ? "已请求手机接续，请解锁并打开一呼" : "已请求手机发送已有数据；刷新台账请在手机操作") : "手机未接受请求，请在手机继续"
            }
        }, errorHandler: { _ in
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
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let data = applicationContext["radar"] as? Data
        Task { @MainActor [weak self] in self?.receive(data) }
    }
}

@main
struct YihuWatchApp: App {
    @State private var link = YihuWatchLink()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TimelineView(.periodic(from: .now, by: 60)) { _ in
                    List {
                        Section {
                            Label(link.connected ? "手机可达" : "手机暂未连接", systemImage: link.connected ? "iphone" : "iphone.slash")
                                .foregroundStyle(link.connected ? Color.secondary : Color.orange)
                            if let notice = link.notice { Text(notice).font(.footnote) }
                            Button("同步手机已有数据") { link.request() }
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
                                                if let notice = link.notice { Text(notice).font(.footnote) }
                                                Text("手表仅查看，不提交回复或改变状态").font(.footnote).foregroundStyle(.secondary)
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
