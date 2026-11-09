import Foundation
import SwiftUI

private func voiceprintText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

/// A local calibration aid, not an identity-verification or automatic model switch.
struct CollieVoiceprintTestView: View {
    let voice: CollieVoiceController
    let store: CollieVoiceprintStore

    init(voice: CollieVoiceController, store: CollieVoiceprintStore = .shared) {
        self.voice = voice
        self.store = store
    }
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(CollieAudioCapturePreferences.nearFieldCaptureKey) private var nearFieldEnabled = true
    @State private var recorder = CollieAudioRecorder()
    @State private var visible = false
    @State private var requesting = false
    @State private var recording = false
    @State private var processing = false
    @State private var generation = UUID()
    @State private var task: Task<Void, Never>?
    @State private var rows: [ScoreRow] = []
    @State private var status: String?
    @State private var hasOldReference = false
    @State private var hasCAMReference = false
    @State private var speaker: Speaker = .owner

    private enum Speaker: String, CaseIterable {
        case owner = "本人"
        case other = "他人"
    }

    private struct ScoreRow: Identifiable {
        let id = UUID()
        let index: Int
        let speaker: Speaker
        let seconds: Double
        let voicedSeconds: Double
        let old: Float?
        let cam: Float?
    }

    var body: some View {
        Form {
            Section {
                Text(voiceprintText("录制一句 1–10 秒的话，查看与本机声纹的匹配得分。"))
                    .fixedSize(horizontal: false, vertical: true)
                if hasOldReference && !store.captureModeMatches(currentNearFieldEnabled: nearFieldEnabled) {
                    Text(CollieVoiceprint.captureModeChangedNotice)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .accessibilityIdentifier("collie-voiceprint-test-capture-mode-warning")
                }
                if !hasOldReference {
                    Label(voiceprintText("请先返回录制本人声纹。"), systemImage: "exclamationmark.circle")
                } else if !hasCAMReference {
                    Label(voiceprintText("CAM++ 暂无基准，当前仅测试 WeSpeaker。"), systemImage: "info.circle")
                }
                Picker(voiceprintText("说话人"), selection: $speaker) {
                    ForEach(Speaker.allCases, id: \.self) { kind in Text(voiceprintText(kind.rawValue)).tag(kind) }
                }
                .pickerStyle(.segmented)
                .disabled(recording || processing)
                .accessibilityIdentifier("collie-voiceprint-test-speaker")
                Button {
                    if recording { stop() } else { start() }
                } label: {
                    Label(recording ? voiceprintText("结束录音") : voiceprintText("开始试音"),
                          systemImage: recording ? "stop.fill" : "waveform")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(recording ? .red : BenchsideStyle.accent)
                .disabled(!recording && (!hasOldReference || requesting || processing || voice.canCancel || voice.phase == .delivering))
                .accessibilityIdentifier("collie-voiceprint-test-record")
                if processing { ProgressView(voiceprintText("正在计算匹配度…")) }
                if let status { Text(status).foregroundStyle(.secondary).accessibilityIdentifier("collie-voiceprint-test-status") }
            } header: { Text(voiceprintText("声纹测试")) } footer: {
                Text(voiceprintText("得分仅在当前页面显示，退出后自动清空。"))
            }
            if !rows.isEmpty {
                Section(voiceprintText("本轮每句得分")) {
                    ForEach(rows) { row in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(format: voiceprintText("第 %lld 句 · %@ · 录音 %@ 秒 / 有效 %@ 秒"), Int64(row.index), voiceprintText(row.speaker.rawValue), String(format: "%.1f", row.seconds), String(format: "%.1f", row.voicedSeconds)))
                                .font(.headline)
                            HStack {
                                Text("WeSpeaker：\(formatted(row.old))")
                                Spacer()
                                Text("CAM++：\(formatted(row.cam))")
                            }
                            .font(.subheadline.monospacedDigit())
                        }
                        .accessibilityIdentifier("collie-voiceprint-test-row-\(row.index)")
                    }
                    if let hint = calibrationHint(\.old, model: "WeSpeaker") { Text(hint).font(.footnote) }
                    if let hint = calibrationHint(\.cam, model: "CAM++") { Text(hint).font(.footnote) }
                    Button(voiceprintText("清空本轮分数")) { rows = []; status = nil }
                }
            }
        }
        .navigationTitle(voiceprintText("声纹测试"))
        .onAppear {
            visible = true
            hasOldReference = store.load() != nil
            hasCAMReference = store.camEmbeddings() != nil
            recorder.onCaptureCompleted = { result in captureCompleted(result) }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                cancel()
                rows = []
                status = voiceprintText("应用已进入后台，请重新测试")
            }
        }
        .onDisappear {
            visible = false
            cancel()
            rows = []
            recorder.onCaptureCompleted = nil
        }
        .onChange(of: voice.phase) { _, _ in
            if (recording || requesting) && (voice.canCancel || voice.phase == .delivering) {
                cancel()
                status = voiceprintText("语音输入已启动，测试录音已安全结束；请重试")
            }
        }
    }

    static func acceptsRecording(_ sampleCount: Int) -> Bool {
        (16_000...11 * 16_000).contains(sampleCount)
    }

    private func calibrationHint(_ score: KeyPath<ScoreRow, Float?>, model: String) -> String? {
        let owner = rows.filter { $0.speaker == .owner }.compactMap { $0[keyPath: score] }
        let others = rows.filter { $0.speaker == .other }.compactMap { $0[keyPath: score] }
        guard let lowestOwner = owner.min(), let highestOther = others.max() else { return nil }
        let gap = lowestOwner > highestOther ? voiceprintText("本轮有间隔，仍需更多真机样本") : voiceprintText("得分重叠，不能可靠设门槛")
        return String(format: voiceprintText("%@：本人最低 %@，他人最高 %@；%@。"), model, formatted(lowestOwner), formatted(highestOther), gap)
    }

    private func formatted(_ value: Float?) -> String {
        guard let value else { return voiceprintText("不可用") }
        return String(format: "%.3f", value)
    }

    private func cancel() {
        generation = UUID()
        task?.cancel()
        task = nil
        recorder.cancel()
        voice.releaseVoiceprintTestMic()
        requesting = false
        recording = false
        processing = false
    }

    private func start() {
        guard visible, scenePhase == .active, !requesting, !processing else { return }
        guard voice.claimVoiceprintTestMic() else {
            status = voiceprintText("语音输入正在使用麦克风，请结束后再测试")
            return
        }
        let token = generation
        requesting = true
        Task {
            let allowed = await recorder.requestPermission()
            guard visible, generation == token else { return }
            requesting = false
            guard scenePhase == .active else {
                voice.releaseVoiceprintTestMic()
                status = voiceprintText("请返回应用后重新测试")
                return
            }
            guard allowed else {
                voice.releaseVoiceprintTestMic()
                status = voiceprintText("请先允许本机麦克风权限")
                return
            }
            do {
                try recorder.start()
                recording = true
                status = voiceprintText("正在录音；请说一句话后结束")
            } catch {
                voice.releaseVoiceprintTestMic()
                status = voiceprintText("无法启动麦克风，请稍后重试")
            }
        }
    }

    private func stop() {
        guard recording else { return }
        recording = false
        processing = true
        recorder.stop()
    }

    private func captureCompleted(_ result: Result<[Float], Error>) {
        guard visible, recording || processing else { return }
        recording = false
        voice.releaseVoiceprintTestMic()
        switch result {
        case .failure:
            processing = false
            status = voiceprintText("录音中断，请重试这一句")
        case .success(let samples):
            guard Self.acceptsRecording(samples.count) else {
                processing = false
                status = voiceprintText("录音请控制在约 1–10 秒；本句未比对")
                return
            }
            let voiced = CollieVoiceprint.voicedRange(samples)
            guard voiced.count >= CollieVoiceprint.minimumVoicedSamples else {
                processing = false
                status = voiceprintText("有效语音不足约 1 秒，本句未比对")
                return
            }
            let token = generation
            task = Task {
                let old = store.load().flatMap(CollieVoiceprint.meanEmbedding)
                let cam = store.camEmbeddings().flatMap(CollieVoiceprint.meanEmbedding)
                let oldCandidate = try? await CollieVoiceprint.embedding(samples, segment: voiced).vector
                let camCandidate = cam == nil ? nil
                    : (try? await CollieCAMPlus.shared.embedding(samples: samples, segment: voiced))
                guard visible, token == generation, !Task.isCancelled else { return }
                // A score requires a locally enrolled reference, never a fixed prototype.
                let oldComparison = old.flatMap { reference in
                    oldCandidate.map { CollieVoiceprint.cosine(reference, $0) }
                }
                let camComparison = cam.flatMap { reference in
                    camCandidate.map { CollieVoiceprint.cosine(reference, $0) }
                }
                let safeOld = oldComparison.flatMap { $0.isFinite ? $0 : nil }
                let safeCAM = camComparison.flatMap { $0.isFinite ? $0 : nil }
                rows.append(ScoreRow(index: rows.count + 1, speaker: speaker,
                                     seconds: Double(samples.count) / 16_000,
                                     voicedSeconds: Double(voiced.count) / 16_000,
                                     old: safeOld, cam: safeCAM))
                processing = false
                task = nil
                status = safeOld == nil ? voiceprintText("WeSpeaker 暂不可用；本句未参与判断") : voiceprintText("本句得分仅供校准，未改变填入门槛")
            }
        }
    }
}
