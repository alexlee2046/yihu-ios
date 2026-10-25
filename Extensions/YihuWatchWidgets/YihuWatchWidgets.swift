import SwiftUI
import WidgetKit

private struct ActionsEntry: TimelineEntry {
    var date: Date
    var snapshot: YihuWatchWidgetSnapshot?
}

private struct ActionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActionsEntry { .init(date: Date(), snapshot: nil) }
    func getSnapshot(in context: Context, completion: @escaping (ActionsEntry) -> Void) {
        completion(.init(date: Date(), snapshot: YihuWatchWidgetStore.load(from: YihuWatchWidgetStore.file)))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ActionsEntry>) -> Void) {
        let now = Date()
        let snapshot = YihuWatchWidgetStore.load(from: YihuWatchWidgetStore.file)
        var dates = [now]
        // Freshness must expire even without a new phone transfer.
        if let expires = snapshot?.sourceDate?.addingTimeInterval(86400), expires > now {
            dates.append(expires)
        }
        completion(Timeline(entries: dates.map { .init(date: $0, snapshot: snapshot) },
                            policy: .after(now.addingTimeInterval(3600))))
    }
}

private struct ActionsWidgetView: View {
    let entry: ActionsEntry
    @Environment(\.widgetFamily) private var family
    private var total: String { entry.snapshot?.total.map(String.init) ?? "—" }
    private var status: String { entry.snapshot?.status(at: entry.date) ?? "请打开一呼同步" }
    private var warning: Bool { entry.snapshot?.needsRefresh(at: entry.date) ?? true }

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Text(warning ? "一呼 · 待刷新" : "一呼 · 待处理 \(total)")
            case .accessoryCircular:
                VStack(spacing: 0) {
                    Image(systemName: warning ? "clock.badge.exclamationmark" : "checklist")
                    Text(total).font(.headline).minimumScaleFactor(0.6)
                }
                .accessibilityLabel("一呼待处理 \(total)，\(status)")
            default:
                VStack(alignment: .leading, spacing: 2) {
                    Text("一呼 · 待我处理").font(.headline)
                    HStack {
                        Link(destination: YihuWatchRoute.decision.url) {
                            Text("决策 \(entry.snapshot?.decisionCount.map(String.init) ?? "—")")
                        }
                        Link(destination: YihuWatchRoute.acceptance.url) {
                            Text("验收 \(entry.snapshot?.acceptanceCount.map(String.init) ?? "—")")
                        }
                    }
                    HStack(spacing: 4) {
                        Text(warning || entry.snapshot?.total == nil ? status : "读取于")
                        if let date = entry.snapshot?.sourceDate, !warning {
                            Text(date, style: .time)
                        }
                    }.font(.caption2).lineLimit(1)
                }
            }
        }
        .privacySensitive()
        .containerBackground(for: .widget) { Color.clear }
        .widgetURL(YihuWatchRoute.all.url)
    }
}

@main
struct YihuWatchActionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: YihuWatchWidgetStore.kind, provider: ActionsProvider()) { entry in
            ActionsWidgetView(entry: entry)
        }
        .configurationDisplayName("一呼待我处理")
        .description("查看手机已有的待决策与待验收数量；更新由系统调度。")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
