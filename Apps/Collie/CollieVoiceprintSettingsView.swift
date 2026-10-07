import Foundation
import SwiftUI

private func voiceprintText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

struct CollieVoiceprintSettingsView: View {
    let voice: CollieVoiceController
    private let store = CollieVoiceprintStore.shared
    @AppStorage(CollieAudioCapturePreferences.nearFieldCaptureKey) private var nearFieldEnabled = true
    @State private var enabled = false
    @State private var enrolled = false
    @State private var recorder = CollieAudioRecorder()
    @State private var vectors: [[Float]] = []
    @State private var camVectors: [[Float]]? = []
    @State private var enrollmentNearFieldEnabled: Bool?
    @State private var enrolledPhraseCount = 0
    @State private var recording = false
    @State private var requestingPermission = false
    @State private var processing = false
    @State private var processingTask: Task<Void, Never>?
    @State private var generation = UUID()
    @State private var visible = false
    @State private var status: String?
    @State private var confirmingDelete = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Form {
            Section {
                Toggle(voiceprintText("只认我的声音"), isOn: $enabled)
                    .disabled(!enrolled && !enabled)
                    .onChange(of: enabled) { _, value in store.isEnabled = value }
                    .accessibilityIdentifier("collie-voiceprint-toggle")
                Text(enrolled ? (enrolledPhraseCount == 3 ? voiceprintText("旧版 3 句声纹：建议重录 6 句") : voiceprintText("已录制 6 句声纹")) : enabled ? voiceprintText("声纹不可用，请重新录制，或关闭开关。") : voiceprintText("尚未录制声纹。先完成录制才能开启。"))
                    .foregroundStyle(.secondary)
                if enrolled && !store.captureModeMatches(currentNearFieldEnabled: nearFieldEnabled) {
                    Text(CollieVoiceprint.captureModeChangedNotice)
                        .foregroundStyle(.orange)
                        .accessibilityIdentifier("collie-voiceprint-capture-mode-warning")
                }
            } header: { Text(voiceprintText("语音输入")) } footer: {
                Text(voiceprintText("仅在语音填入前比对，不影响语音记录；有效语音不足约 1 秒才保留文字供手动确认，1–2 秒照常比对。声纹只保存在本机、不上传、不备份；可能误判，不可用于身份验证。"))
            }
            Section {
                Text(voiceprintText("按顺序念 6 句，每句约 5–10 秒。前 3 句在安静环境，后 3 句请换到不同的日常环境（例如窗边或室外），正常音量说话。旧声纹保留至六句全部录完。"))
                if vectors.count < CollieVoiceprint.enrollmentPhraseCount {
                    Text(String(format: voiceprintText("第 %lld 句 · %@：%@"), Int64(vectors.count + 1), vectors.count < 3 ? voiceprintText("安静环境") : voiceprintText("另一日常环境"), CollieVoiceprint.prompts[vectors.count]))
                        .font(.headline)
                        .accessibilityIdentifier("collie-voiceprint-prompt")
                }
                Button(recording ? voiceprintText("结束这一句") : voiceprintText("开始录制")) {
                    if recording { stop() } else { start() }
                }
                .disabled(requestingPermission || processing || voice.isRecording || vectors.count == CollieVoiceprint.enrollmentPhraseCount)
                .accessibilityIdentifier("collie-voiceprint-record")
                if processing { ProgressView(voiceprintText("正在本机提取声纹…")) }
                if let status { Text(status).foregroundStyle(.secondary).accessibilityIdentifier("collie-voiceprint-status") }
                if !vectors.isEmpty && !recording {
                    Button(voiceprintText("重新录制六句")) { vectors = []; camVectors = []; status = nil }
                        .disabled(processing || requestingPermission)
                }
            } header: { Text(enrolled ? voiceprintText("重录声纹") : voiceprintText("录制声纹")) } footer: {
                Text(voiceprintText("WeSpeaker 暂继续用于填入前确认；CAM++ 仅作本机对照候选。两模型的实际得分可在下方测试页查看，不能直接比较分数高低。"))
            }
            Section {
                NavigationLink(voiceprintText("声纹测试（两模型得分）")) {
                    CollieVoiceprintTestView(voice: voice)
                }
                .disabled(recording || processing || requestingPermission || !vectors.isEmpty)
                .accessibilityIdentifier("collie-voiceprint-test-link")
            } footer: {
                Text(voiceprintText("使用本机麦克风录制不同环境的多句短语。显示每句与本人基准的余弦得分；不同模型没有统一阈值，需用真实本人及他人声音数据校准。"))
                if !vectors.isEmpty { Text(voiceprintText("请先录完六句或重新开始，本轮未完成时不可进入测试页。")) }
            }
            if enrolled || enabled {
                Section {
                    Button(voiceprintText("删除声纹"), role: .destructive) { confirmingDelete = true }
                        .disabled(recording || processing || requestingPermission)
                        .accessibilityIdentifier("collie-voiceprint-delete")
                }
            }
        }
        .navigationTitle(voiceprintText("只认我的声音"))
        .confirmationDialog(voiceprintText("删除本机声纹？"), isPresented: $confirmingDelete) {
            Button(voiceprintText("删除声纹"), role: .destructive) {
                guard !recording && !processing && !requestingPermission else { return }
                do {
                    try store.delete()
                    enrolled = false; enabled = false; enrolledPhraseCount = 0; vectors = []; camVectors = []; status = voiceprintText("声纹已从本机删除")
                } catch {
                    enabled = store.isEnabled
                    enrolledPhraseCount = store.load()?.count ?? 0
                    enrolled = enrolledPhraseCount > 0
                    status = voiceprintText("删除失败，请重试")
                }
            }
        }
        .onAppear {
            visible = true
            enabled = store.isEnabled
            enrolledPhraseCount = store.load()?.count ?? 0
            enrolled = enrolledPhraseCount > 0
            recorder.onCaptureCompleted = { result in captureCompleted(result) }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                let hadRound = recording || requestingPermission || processing || !vectors.isEmpty
                cancelRound()
                if hadRound { status = voiceprintText("已进入后台，请重新录制六句") }
            }
        }
        .onDisappear {
            visible = false
            cancelRound()
            recorder.onCaptureCompleted = nil
        }
    }

    private func cancelRound() {
        generation = UUID()
        processingTask?.cancel()
        processingTask = nil
        recorder.cancel()
        requestingPermission = false
        recording = false
        processing = false
        vectors = []
        camVectors = []
        enrollmentNearFieldEnabled = nil
        status = nil
    }

    private func start() {
        guard visible && scenePhase == .active && !requestingPermission && !processing else { return }
        let modeChanged = enrollmentNearFieldEnabled.map { $0 != nearFieldEnabled } ?? false
        if modeChanged {
            vectors = []
            camVectors = []
        }
        enrollmentNearFieldEnabled = nearFieldEnabled
        let token = generation
        requestingPermission = true
        Task {
            let allowed = await recorder.requestPermission()
            guard visible && generation == token else { return }
            requestingPermission = false
            guard scenePhase == .active else { status = voiceprintText("请返回应用后重新录制"); return }
            guard allowed else { status = voiceprintText("无法使用麦克风，请检查权限"); return }
            do {
                try recorder.start()
                recording = true
                let progress = String(format: voiceprintText("正在录制第 %lld 句（5–10 秒）"), Int64(vectors.count + 1))
                status = modeChanged ? "\(CollieVoiceprint.captureModeChangedNotice)；\(progress)" : progress
            } catch { status = voiceprintText("无法使用麦克风，请检查权限") }
        }
    }

    private func stop() {
        guard recording else { return }
        recording = false
        processing = true // Wait for the recorder to drain its final PCM before reading it.
        recorder.stop()
        status = voiceprintText("正在结束录音…")
    }

    private func captureCompleted(_ result: Result<[Float], Error>) {
        guard visible && (recording || processing) else { return }
        recording = false // Also covers the 30 s timer and system interruption.
        switch result {
        case .failure:
            processing = false
            status = voiceprintText("录音被系统中断，请重试这一句")
        case .success(let samples):
            guard samples.count >= 5 * 16_000, samples.count <= 11 * 16_000 else {
                processing = false
                status = samples.count > 11 * 16_000 ? voiceprintText("录音已超时，请将每句控制在约 5–10 秒") : voiceprintText("每句请录制约 5–10 秒，再试一次")
                return
            }
            let voiced = CollieVoiceprint.voicedRange(samples)
            guard voiced.count >= CollieVoiceprint.enrollmentMinimumVoicedSamples else {
                processing = false
                status = voiceprintText("有效语音不足约 2 秒，请重录这一句")
                return
            }
            processing = true
            let token = generation
            processingTask = Task {
                let vector = try? await CollieVoiceprint.embedding(samples, segment: voiced).vector
                let camVector = camVectors == nil ? nil
                    : (try? await CollieCAMPlus.shared.embedding(samples: samples, segment: voiced))
                guard visible && generation == token && !Task.isCancelled else { return }
                processing = false
                processingTask = nil
                guard let vector else { status = voiceprintText("有效语音不足或 WeSpeaker 不可用，请重试"); return }
                let next = vectors + [vector]
                guard CollieVoiceprint.enrollmentIsConsistent(next) else {
                    vectors = []; camVectors = []
                    status = voiceprintText("录音间差异过大，请确认均为本人并重新录制六句")
                    return
                }
                vectors = next
                if let currentCAM = camVectors {
                    if let camVector {
                        let nextCAM = currentCAM + [camVector]
                        camVectors = CollieVoiceprint.enrollmentIsConsistent(nextCAM) ? nextCAM : nil
                    } else { camVectors = nil }
                }
                let camAvailable = camVectors != nil
                if vectors.count == CollieVoiceprint.enrollmentPhraseCount {
                    do {
                        try store.save(vectors, camEmbeddings: camVectors,
                                       nearFieldCaptureEnabled: enrollmentNearFieldEnabled ?? nearFieldEnabled)
                        enrolled = true
                        enrolledPhraseCount = vectors.count
                        vectors = []; camVectors = []; enrollmentNearFieldEnabled = nil
                        status = camAvailable
                            ? voiceprintText("六句声纹已保存在本机，可打开测试页查看两模型得分")
                            : voiceprintText("WeSpeaker 声纹已保存；CAM++ 本轮不可用，测试页仅显示 WeSpeaker 得分")
                    } catch CollieVoiceprint.VoiceprintError.legacyRemovalFailed {
                        enrolled = true; enrolledPhraseCount = CollieVoiceprint.enrollmentPhraseCount
                        vectors = []; camVectors = []
                        status = voiceprintText("新声纹已保存，但旧版声纹清理失败；请删除声纹后重新录制")
                    } catch { status = voiceprintText("保存失败，旧声纹仍有效，请重试") }
                } else {
                    status = camAvailable
                        ? String(format: voiceprintText("第 %lld 句已完成，请继续换环境录制"), Int64(vectors.count))
                        : String(format: voiceprintText("第 %lld 句已完成；CAM++ 本轮不可用，仍可完成 WeSpeaker 注册"), Int64(vectors.count))
                }
            }
        }
    }
}
