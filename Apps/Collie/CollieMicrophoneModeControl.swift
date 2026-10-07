import AVFoundation
import SwiftUI

struct CollieMicrophoneModeControl: View {
    var compact = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeMode = AVCaptureDevice.activeMicrophoneMode

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 8) {
            Label(String(format: NSLocalizedString("当前麦克风模式：%@", tableName: "Yihu", comment: ""), title(for: activeMode)), systemImage: "mic")
                .font(compact ? .footnote : .body)
                .accessibilityLabel(String(format: NSLocalizedString("当前麦克风模式：%@", tableName: "Yihu", comment: ""), title(for: activeMode)))
            Button {
                AVCaptureDevice.showSystemUserInterface(.microphoneModes)
            } label: {
                Label(NSLocalizedString("打开系统麦克风模式", tableName: "Yihu", comment: ""), systemImage: "slider.horizontal.3")
            }
            .font(compact ? .footnote : .body)
            if !compact {
                Text(NSLocalizedString("人声突显：只收离手机最近的人声，适合旁边有人说话时。系统模式会在支持的音频路由上生效。", tableName: "Yihu", comment: ""))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear(perform: refresh)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
    }

    private func refresh() {
        activeMode = AVCaptureDevice.activeMicrophoneMode
    }

    private func title(for mode: AVCaptureDevice.MicrophoneMode) -> String {
        switch mode {
        case .standard: NSLocalizedString("标准", tableName: "Yihu", comment: "")
        case .voiceIsolation: NSLocalizedString("人声突显", tableName: "Yihu", comment: "")
        case .wideSpectrum: NSLocalizedString("宽频谱", tableName: "Yihu", comment: "")
        @unknown default: NSLocalizedString("系统模式", tableName: "Yihu", comment: "")
        }
    }
}
