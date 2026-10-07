import AVFoundation
import SwiftUI

struct CollieMicrophoneModeControl: View {
    var compact = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeMode = AVCaptureDevice.activeMicrophoneMode

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 8) {
            Label("当前麦克风模式：\(title(for: activeMode))", systemImage: "mic")
                .font(compact ? .footnote : .body)
                .accessibilityLabel("当前麦克风模式：\(title(for: activeMode))")
            Button {
                AVCaptureDevice.showSystemUserInterface(.microphoneModes)
            } label: {
                Label("打开系统麦克风模式", systemImage: "slider.horizontal.3")
            }
            .font(compact ? .footnote : .body)
            if !compact {
                Text("人声突显：只收离手机最近的人声，适合旁边有人说话时。系统模式会在支持的音频路由上生效。")
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
        case .standard: "标准"
        case .voiceIsolation: "人声突显"
        case .wideSpectrum: "宽频谱"
        @unknown default: "系统模式"
        }
    }
}
