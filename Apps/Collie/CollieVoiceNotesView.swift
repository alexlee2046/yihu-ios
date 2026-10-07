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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                recordCard
            } footer: {
                Text(notesText("录音在这台 iPhone 上转写。锁屏后会继续录音；转写在一呼打开时进行。交给工作台时分享转写文字，不包含录音文件。"))
            }
            if let notice = store.notice {
                Section { Text(notice).font(.footnote).foregroundStyle(.orange) }
            }
            if !store.notes.filter({ $0.status != .recording }).isEmpty {
                Section(notesText("记录")) {
                    ForEach(store.notes.filter { $0.status != .recording }) { note in
                        NavigationLink {
                            CollieVoiceNoteDetail(store: store, note: note) {
                                dismiss()
                                onHandedOff()
                            }
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
            }
            Button {
                Task {
                    if store.recorder.isRecording { await store.stopRecording() } else { await store.startRecording() }
                }
            } label: {
                Label(store.recorder.isRecording ? notesText("结束记录") : notesText("开始记录"),
                      systemImage: store.recorder.isRecording ? "stop.fill" : "record.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(store.recorder.isRecording ? .red : BenchsideStyle.accent)
            .accessibilityIdentifier("collie-note-record")
        }
        .padding(.vertical, 8)
    }

    private func row(_ note: CollieVoiceNote) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.createdAt, format: .dateTime.month().day().hour().minute())
                    .font(.body.weight(.medium))
                Spacer()
                Text(Self.clock(note.duration)).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            switch note.status {
            case .done:
                Text(note.transcript).font(.caption).foregroundStyle(.secondary).lineLimit(2)
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
        .padding(.vertical, 2)
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

    static let instructions = [
        "请把下面的录音整理成会议纪要：结论、讨论要点、待办（负责人和时间）。",
        "请把下面的录音整理成要点清单，并列出需要我跟进的事项。",
        "下面是我的语音记录，请帮我整理成通顺的文字，不要遗漏信息。",
    ]
    @State private var instruction = Self.instructions[0]
    @State private var handOffError: String?

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
                    Text(notesText("要点和待办")).tag(Self.instructions[1])
                    Text(notesText("整理成文字")).tag(Self.instructions[2])
                }
                Button(notesText("交给当前工作台")) {
                    handOffError = store.handOff(current, instruction: instruction, inbox: CollieShareInbox.shared())
                    if handOffError == nil { onHandedOff() }
                }
                .disabled(current.status != .done)
                .accessibilityIdentifier("collie-note-handoff")
                Button(notesText("复制全文")) { UIPasteboard.general.string = current.transcript }
                    .disabled(current.transcript.isEmpty)
                if let handOffError {
                    Text(handOffError).font(.footnote).foregroundStyle(.orange)
                }
            } footer: {
                Text(notesText("会放进「收到分享」，回到工作台点一下输入框，再点「填入」。长转写以文本附件形式交给工作台。不会自动发送。"))
            }
        }
        .navigationTitle(current.createdAt.formatted(.dateTime.month().day().hour().minute()))
        .navigationBarTitleDisplayMode(.inline)
    }
}
