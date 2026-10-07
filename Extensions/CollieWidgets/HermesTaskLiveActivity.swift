import ActivityKit
import SwiftUI
import WidgetKit

@main
struct CollieWidgetsBundle: WidgetBundle {
    var body: some Widget {
        HermesTaskLiveActivity()
    }
}

/// Lock Screen and Dynamic Island view for a Hermes task started from the WebUI.
struct HermesTaskLiveActivity: Widget {
    private static let accent = Color(red: 0.40, green: 0.83, blue: 0.81)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HermesTaskAttributes.self) { context in
            HStack(spacing: 12) {
                icon(context.state).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hermes").font(.headline)
                    Text(context.state.phaseText).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                elapsed(context.state).font(.subheadline.monospacedDigit())
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.75))
            .activitySystemActionForegroundColor(Self.accent)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Hermes", systemImage: "sparkles").font(.headline).foregroundStyle(Self.accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    elapsed(context.state).font(.headline.monospacedDigit())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.phaseText).font(.subheadline).lineLimit(1)
                }
            } compactLeading: {
                icon(context.state)
            } compactTrailing: {
                elapsed(context.state).monospacedDigit().frame(maxWidth: 48)
            } minimal: {
                icon(context.state)
            }
            .keylineTint(Self.accent)
        }
    }

    @ViewBuilder
    private func icon(_ state: HermesTaskAttributes.ContentState) -> some View {
        switch state.phase {
        case "done": Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case "failed": Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
        case "interrupted": Image(systemName: "pause.circle.fill").foregroundStyle(.orange)
        default: Image(systemName: "sparkles").foregroundStyle(Self.accent)
        }
    }

    @ViewBuilder
    private func elapsed(_ state: HermesTaskAttributes.ContentState) -> some View {
        let start = Date(timeIntervalSince1970: state.startedAt)
        if state.isFinished {
            let end = Date(timeIntervalSince1970: state.updatedAt ?? state.startedAt)
            Text(Duration.seconds(max(0, end.timeIntervalSince(start))), format: .time(pattern: .minuteSecond))
        } else {
            Text(timerInterval: start...Date.distantFuture, countsDown: false)
        }
    }
}
