import Foundation
import SwiftUI
import WatchConnectivity
import WatchKit

/// Anti-accidental-tap micro-approval for Apple Watch.
/// Requires holding for 1.5 seconds with haptic feedback before queueing an approval proposal to the phone.
struct YihuWatchHoldToApproveView: View {
    let item: YihuWatchSnapshot.Item
    var onCompleted: () -> Void = {}

    enum ActionType: String, CaseIterable {
        case approve = "确认同意"
        case reject = "驳回修改"

        var color: Color {
            switch self {
            case .approve: return .green
            case .reject: return .orange
            }
        }

        var prefix: String {
            switch self {
            case .approve: return "【手表微审批】同意通过"
            case .reject: return "【手表微审批】驳回并建议调整"
            }
        }
    }

    @State private var selectedAction: ActionType = .approve
    @State private var progress: Double = 0
    @State private var isPressing = false
    @State private var isTransmitting = false
    @State private var notice: String?
    @State private var requestID = UUID()

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Button {
                    selectedAction = .approve
                } label: {
                    Text(ActionType.approve.rawValue)
                        .font(.footnote.weight(selectedAction == .approve ? .bold : .regular))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedAction == .approve ? .green.opacity(0.8) : .gray.opacity(0.25))

                Button {
                    selectedAction = .reject
                } label: {
                    Text(ActionType.reject.rawValue)
                        .font(.footnote.weight(selectedAction == .reject ? .bold : .regular))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedAction == .reject ? .orange.opacity(0.8) : .gray.opacity(0.25))
            }
            .disabled(isPressing || isTransmitting)

            holdButton

            if let notice {
                Text(notice)
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 4)
    }

    private var holdButton: some View {
        ZStack {
            // Background fill bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedAction.color.opacity(0.2))
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedAction.color)
                        .frame(width: proxy.size.width * CGFloat(progress))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 6) {
                if isTransmitting {
                    ProgressView().tint(.white)
                    Text("正在交接…").font(.footnote.weight(.semibold)).foregroundStyle(.white)
                } else if isPressing {
                    Image(systemName: "hand.tap.fill").foregroundStyle(.white)
                    Text("按住不放 (1.5s)").font(.footnote.weight(.bold)).foregroundStyle(.white)
                } else {
                    Image(systemName: selectedAction == .approve ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(selectedAction.color)
                    Text("长按\(selectedAction.rawValue)")
                        .font(.footnote.weight(.semibold))
                }
            }
            .padding(.vertical, 12)
        }
        .frame(height: 44)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onLongPressGesture(minimumDuration: 1.5, perform: {
            // Reached full 1.5s
            WKInterfaceDevice.current().play(.success)
            withAnimation(.easeOut(duration: 0.2)) {
                progress = 1.0
                isPressing = false
            }
            submitApproval()
        }, onPressingChanged: { pressing in
            guard !isTransmitting else { return }
            isPressing = pressing
            if pressing {
                WKInterfaceDevice.current().play(.click)
                withAnimation(.linear(duration: 1.5)) {
                    progress = 1.0
                }
            } else if progress < 1.0 {
                // User released early: abort safely
                withAnimation(.easeOut(duration: 0.15)) {
                    progress = 0
                }
                WKInterfaceDevice.current().play(.retry)
            }
        })
        .disabled(isTransmitting || item.sourceToken == nil || item.taskToken == nil)
    }

    private func submitApproval() {
        guard let sourceToken = item.sourceToken, let taskToken = item.taskToken else {
            notice = "数据版本较旧，请在手机刷新"
            return
        }
        guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
            notice = "手机未连接，无法交接手腕审批"
            return
        }
        isTransmitting = true
        notice = nil

        let proposalText = "\(selectedAction.prefix)：\(item.title)"
        let draft = YihuWatchDraft(
            requestID: requestID,
            workbench: item.workbench,
            task: item.task,
            sourceToken: sourceToken,
            taskToken: taskToken,
            text: proposalText,
            transferAttempted: true
        )

        guard let data = try? JSONEncoder().encode(draft) else {
            isTransmitting = false
            notice = "提案打包失败，请重试"
            return
        }

        WCSession.default.sendMessage(["kind": "draft", "draft": data], replyHandler: { response in
            let state = response["state"] as? String ?? "unavailable"
            Task { @MainActor in
                isTransmitting = false
                switch state {
                case "saved":
                    WKInterfaceDevice.current().play(.directionUp)
                    notice = "审批草稿已存入手机，待手机最终确认写入"
                    onCompleted()
                case "changed":
                    WKInterfaceDevice.current().play(.failure)
                    notice = "事项已变更或已被处理，请刷新"
                case "busy":
                    WKInterfaceDevice.current().play(.failure)
                    notice = "手机正忙，请稍后重试"
                default:
                    WKInterfaceDevice.current().play(.failure)
                    notice = "手机未确认保存，请在手机核对"
                }
            }
        }, errorHandler: { _ in
            Task { @MainActor in
                isTransmitting = false
                WKInterfaceDevice.current().play(.failure)
                notice = "与手机通信超时，请靠近手机后重试"
            }
        })
    }
}
