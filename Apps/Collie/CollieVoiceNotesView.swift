import Foundation
import SwiftUI

private func notesText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

/// Long voice notes: record, watch on-device transcription, then hand the text
/// (with an instruction) to the current workbench through the share tray.
struct CollieVoiceNotesView: View {
    let store: CollieVoiceNotesStore
    var onHandedOff: () -> Void = {}
    var onDirectInsert: ((String, UUID) async -> Bool)? = nil
    var radarCandidates: [CollieRadarStore.DraftTargetCandidate] = []
    var onSaveRadarDraft: ((String, UUID, CollieRadarStore.DraftTargetCandidate) -> Bool)? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                recordCard
            } footer: {
                Text(notesText("本机离线转写，锁屏后仍可继续录音。"))
            }
            if let notice = store.notice {
                Section { Text(notice).font(.footnote).foregroundStyle(.orange) }
            }
            if !store.notes.filter({ $0.status != .recording }).isEmpty {
                Section(notesText("记录")) {
                    ForEach(store.notes.filter { $0.status != .recording }) { note in
                        NavigationLink {
                            CollieVoiceNoteDetail(store: store, note: note, onHandedOff: {
                                dismiss()
                                onHandedOff()
                            }, onDirectInsert: onDirectInsert, radarCandidates: radarCandidates,
                               onSaveRadarDraft: onSaveRadarDraft)
                        } label: {
                            row(note)
                        }
                    }
                    .onDelete { offsets in
                        let visible = store.notes.filter { $0.status != .recording }
                        offsets.map { visible[$0] }.forEach(store.delete)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(notesText("语音记录"))
        .navigationBarTitleDisplayMode(.inline)
        .tint(BenchsideStyle.accent)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button(notesText("完成")) { dismiss() } }
        }
        .onAppear { store.resumeTranscription() }
    }

    private var recordCard: some View {
        VStack(spacing: 14) {
            if store.recorder.isRecording, let startedAt = store.recorder.startedAt {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(Self.clock(context.date.timeIntervalSince(startedAt)))
                        .font(.system(.largeTitle, design: .rounded).monospacedDigit().weight(.semibold))
                }
                ProgressView(value: Double(store.recorder.level))
                    .tint(.red)
                    .accessibilityLabel(notesText("麦克风音量"))
            } else {
                HStack(spacing: 12) {
                    BenchsideStyle.rowBadge("waveform")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(notesText("长语音闪念"))
                            .font(.subheadline.weight(.semibold))
                        Text(notesText("本机离线转写，锁屏可持续录音"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            Button {
                Task {
                    if store.recorder.isRecording { await store.stopRecording() } else { await store.startRecording() }
                }
            } label: {
                Label(store.recorder.isRecording ? notesText("结束记录") : notesText("开始记录"),
                      systemImage: store.recorder.isRecording ? "stop.fill" : "record.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(store.recorder.isRecording ? .red : BenchsideStyle.accent)
            .accessibilityIdentifier("collie-note-record")
        }
        .padding(.vertical, 6)
    }

    private func row(_ note: CollieVoiceNote) -> some View {
        HStack(alignment: .top, spacing: 12) {
            BenchsideStyle.rowBadge(
                note.status == .done ? "waveform.circle.fill" : (note.status == .failed ? "exclamationmark.circle" : "ellipsis.circle"),
                tint: note.status == .failed ? .red : BenchsideStyle.accent
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.createdAt, format: .dateTime.month().day().hour().minute())
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(Self.clock(note.duration))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(BenchsideStyle.surfaceMuted))
                }
                switch note.status {
                case .done:
                    Text(note.transcript).font(.footnote).foregroundStyle(.secondary).lineLimit(2)
                case .transcribing, .pending:
                    ProgressView(value: store.progress[note.id] ?? 0) {
                        Text(note.status == .pending ? notesText("等待转写") : notesText("正在转写")).font(.caption)
                    }
                case .failed:
                    Text(note.failure ?? notesText("转写失败")).font(.caption).foregroundStyle(.red)
                case .recording:
                    EmptyView()
                }
            }
        }
        .padding(.vertical, 4)
    }

    static func clock(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        return total >= 3_600
            ? String(format: "%d:%02d:%02d", total / 3_600, total % 3_600 / 60, total % 60)
            : String(format: "%02d:%02d", total / 60, total % 60)
    }
}

struct CollieVoiceNoteDetail: View {
    let store: CollieVoiceNotesStore
    let note: CollieVoiceNote
    let onHandedOff: () -> Void
    var onDirectInsert: ((String, UUID) async -> Bool)? = nil
    var radarCandidates: [CollieRadarStore.DraftTargetCandidate] = []
    var onSaveRadarDraft: ((String, UUID, CollieRadarStore.DraftTargetCandidate) -> Bool)? = nil

    static let instructions = [
        "请把下面的录音整理成会议纪要：结论、讨论要点、待办（负责人和时间）。",
        "请把下面的录音整理成要点清单，并列出需要我跟进的事项。",
        "下面是我的语音记录，请帮我整理成通顺的文字，不要遗漏信息。",
    ]
    @State private var instruction = Self.instructions[0]
    @State private var handOffError: String?
    @State private var isHandingOff = false

    private var current: CollieVoiceNote { store.notes.first { $0.id == note.id } ?? note }

    var body: some View {
        Form {
            Section(notesText("转写")) {
                if current.transcript.isEmpty {
                    Text(current.status == .failed ? (current.failure ?? notesText("转写失败")) : notesText("正在转写…"))
                        .foregroundStyle(.secondary)
                } else {
                    Text(current.transcript).textSelection(.enabled)
                }
                if current.status == .failed {
                    Button(notesText("重新转写")) { store.retry(current) }
                }
            }
            Section {
                Picker(notesText("整理方式"), selection: $instruction) {
                    Text(notesText("会议纪要")).tag(Self.instructions[0])
                    Text(notesText("要点与待办")).tag(Self.instructions[1])
                    Text(notesText("润色成文")).tag(Self.instructions[2])
                }
                .disabled(isHandingOff || current.handOffAttempted == true)
                if let onDirectInsert {
                    Button {
                        guard !isHandingOff, current.handOffAttempted != true else { return }
                        let text = instruction.isEmpty ? current.transcript : "\(instruction)\n\n\(current.transcript)"
                        let id = current.id
                        isHandingOff = true
                        Task {
                            defer { isHandingOff = false }
                            if await onDirectInsert(text, id) { onHandedOff() }
                            else {
                                handOffError = notesText("未能填入，请先点选输入框或直接复制。")
                            }
                        }
                    } label: {
                        Label(notesText("填入当前输入框"), systemImage: "arrow.up.doc")
                            .frame(minHeight: 44)
                    }
                    .disabled(current.status != .done || current.transcript.count > 3_000 ||
                              current.handOffAttempted == true || isHandingOff)
                    .accessibilityIdentifier("collie-note-direct-insert")
                }
                if let onSaveRadarDraft, !radarCandidates.isEmpty {
                    Menu {
                        ForEach(radarCandidates) { candidate in
                            Button("\(candidate.workbenchName) · \(candidate.action.title)") {
                                guard !isHandingOff, current.handOffAttempted != true else { return }
                                isHandingOff = true
                                defer { isHandingOff = false }
                                if onSaveRadarDraft(current.transcript, current.id, candidate) {
                                    onHandedOff()
                                } else {
                                    handOffError = notesText("无法保存草稿，请确认该事项仍在待处理列表。")
                                }
                            }
                        }
                    } label: {
                        Label(notesText("存为雷达草稿"), systemImage: "scope")
                            .frame(minHeight: 44)
                    }
                    .disabled(current.status != .done || current.transcript.unicodeScalars.count > 4_000 ||
                              current.handOffAttempted == true || isHandingOff)
                    .accessibilityIdentifier("collie-note-radar-draft")
                }
                Button {
                    guard !isHandingOff, current.handOffAttempted != true else { return }
                    isHandingOff = true
                    defer { isHandingOff = false }
                    handOffError = store.handOff(current, instruction: instruction, inbox: CollieShareInbox.shared())
                    if handOffError == nil { onHandedOff() }
                } label: {
                    Label(notesText("暂存到分享托盘"), systemImage: "tray.and.arrow.down")
                        .frame(minHeight: 44)
                }
                .disabled(current.status != .done || current.handOffAttempted == true || isHandingOff)
                .accessibilityIdentifier("collie-note-handoff")
                Button {
                    UIPasteboard.general.string = current.transcript
                } label: {
                    Label(notesText("复制全文"), systemImage: "doc.on.doc")
                        .frame(minHeight: 44)
                }
                .disabled(current.transcript.isEmpty)
                if current.handOffAttempted == true {
                    Text(notesText("已交接过一次，如需再次使用请直接复制全文。"))
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if let handOffError {
                    Text(handOffError).font(.footnote).foregroundStyle(.orange)
                }
            } footer: {
                Text(notesText("填入或暂存后不会自动发送，可在工作台确认后再提交。"))
            }
        }
        .navigationTitle(current.createdAt.formatted(.dateTime.month().day().hour().minute()))
        .navigationBarTitleDisplayMode(.inline)
    }
}
