@preconcurrency import AVFoundation
import Foundation
import Observation

struct CollieVoiceNote: Codable, Equatable, Identifiable, Sendable {
    enum Status: String, Codable, Sendable { case recording, pending, transcribing, done, failed }

    var id = UUID()
    var createdAt = Date()
    var duration: TimeInterval = 0
    var status: Status = .recording
    var transcript = ""
    /// 16 kHz frames already transcribed, so an interrupted pass resumes.
    var transcribedFrames: Int64 = 0
    var failure: String?
}

/// Splits long audio into recognizer-sized pieces at the quietest moment near
/// the end of each window, so words are rarely cut in half.
enum CollieNoteSegmenter {
    static let sampleRate = 16_000
    static let maxSeconds = 28
    static let searchSeconds = 8
    static let frameSize = 1_600 // 100 ms

    /// Frames to keep from `window` (which starts at a segment boundary). A final
    /// window shorter than the maximum is kept whole.
    static func cutPoint(in window: [Float], isFinal: Bool) -> Int {
        let maxFrames = maxSeconds * sampleRate
        guard window.count >= maxFrames, !isFinal else { return window.count }
        let searchStart = (maxSeconds - searchSeconds) * sampleRate
        var best = maxFrames
        var bestEnergy = Float.greatestFiniteMagnitude
        var start = searchStart
        while start + frameSize <= maxFrames {
            var energy: Float = 0
            for index in start..<(start + frameSize) { energy += window[index] * window[index] }
            if energy < bestEnergy { bestEnergy = energy; best = start + frameSize / 2 }
            start += frameSize
        }
        return best
    }

    /// Joins recognized pieces; a space only between two Latin letters/digits.
    static func join(_ existing: String, _ next: String) -> String {
        guard !existing.isEmpty else { return next }
        guard let left = existing.last, let right = next.first else { return existing + next }
        let latin: (Character) -> Bool = { $0.isASCII && ($0.isLetter || $0.isNumber) }
        return existing + (latin(left) && latin(right) ? " " : "") + next
    }
}

/// Voice notes: record (screen may lock), then transcribe on device segment by
/// segment with the same model and term list as dictation. Notes live in
/// Application Support/VoiceNotes/<id>/ as note.json + audio.caf.
@MainActor
@Observable
final class CollieVoiceNotesStore {
    private(set) var notes: [CollieVoiceNote] = []
    private(set) var progress: [UUID: Double] = [:]
    private(set) var notice: String?
    let recorder = CollieNoteRecorder()

    private let root: URL
    private let transcriber: any CollieTranscribing
    private let canTranscribe: () -> Bool
    private let terms: () -> [String]
    private let canRecord: () -> Bool
    private var worker: Task<Void, Never>?
    private var recordingID: UUID?
    private var isStarting = false
    private var deleted: Set<UUID> = []

    init(root: URL = URL.applicationSupportDirectory.appending(path: "VoiceNotes", directoryHint: .isDirectory),
         transcriber: any CollieTranscribing,
         canTranscribe: @escaping () -> Bool = { true },
         terms: @escaping () -> [String] = { [] },
         canRecord: @escaping () -> Bool = { true }) {
        self.root = root
        self.transcriber = transcriber
        self.canTranscribe = canTranscribe
        self.terms = terms
        self.canRecord = canRecord
        // Audio and transcripts stay on this iPhone: keep them out of iCloud/device backups.
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        var excluded = root
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? excluded.setResourceValues(values)
        load()
        recorder.onInterrupted = { [weak self] reason in
            Task { @MainActor in
                await self?.stopRecording()
                self?.notice = reason
            }
        }
    }

    func audioURL(for id: UUID) -> URL { root.appending(path: "\(id.uuidString)/audio.caf") }
    private func metaURL(for id: UUID) -> URL { root.appending(path: "\(id.uuidString)/note.json") }

    func load() {
        let entries = (try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? []
        notes = entries.compactMap { (directory: URL) -> CollieVoiceNote? in
            guard let data = try? Data(contentsOf: directory.appending(path: "note.json")) else { return nil }
            return try? JSONDecoder().decode(CollieVoiceNote.self, from: data)
        }
        .map { (note: CollieVoiceNote) -> CollieVoiceNote in
            // A note left "recording" or "transcribing" by a killed app resumes as pending.
            var note = note
            if note.status == .recording || note.status == .transcribing { note.status = .pending }
            return note
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    private func save(_ note: CollieVoiceNote) {
        guard !deleted.contains(note.id) else { return }
        if let index = notes.firstIndex(where: { $0.id == note.id }) { notes[index] = note } else { notes.insert(note, at: 0) }
        try? FileManager.default.createDirectory(at: metaURL(for: note.id).deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(note) { try? data.write(to: metaURL(for: note.id), options: .atomic) }
    }

    func startRecording() async {
        guard !recorder.isRecording, !isStarting else { return }
        guard canRecord() else {
            notice = "正在语音输入，结束后再开始记录。"
            return
        }
        isStarting = true
        defer { isStarting = false }
        guard await recorder.requestPermission() else {
            notice = "麦克风权限已关闭，请在系统设置中允许一呼使用麦克风。"
            return
        }
        let note = CollieVoiceNote()
        save(note)
        do {
            try recorder.start(writingTo: audioURL(for: note.id))
            recordingID = note.id
            notice = nil
        } catch {
            delete(note)
            notice = "无法开始记录：麦克风暂时不可用。"
        }
    }

    func stopRecording() async {
        guard let id = recordingID, var note = notes.first(where: { $0.id == id }) else { return }
        recordingID = nil
        let frames = await recorder.stop()
        note.duration = Double(frames) / Double(CollieNoteSegmenter.sampleRate)
        note.status = frames > 0 ? .pending : .failed
        note.failure = frames > 0 ? nil : "没有录到声音。"
        save(note)
        resumeTranscription()
    }

    func delete(_ note: CollieVoiceNote) {
        guard note.id != recordingID else { return }
        deleted.insert(note.id)
        let wasTranscribing = notes.first(where: { $0.id == note.id })?.status == .transcribing
        if wasTranscribing { pauseTranscription() }
        defer { if wasTranscribing { resumeTranscription() } }
        try? FileManager.default.removeItem(at: metaURL(for: note.id).deletingLastPathComponent())
        notes.removeAll { $0.id == note.id }
        progress[note.id] = nil
    }

    func retry(_ note: CollieVoiceNote) {
        var note = note
        note.status = .pending
        note.failure = nil
        save(note)
        resumeTranscription()
    }

    /// Works through pending notes one at a time while the app is in front and
    /// dictation is idle; safe to call repeatedly.
    func resumeTranscription() {
        guard worker == nil else { return }
        worker = Task { [weak self] in
            while let self, let next = self.notes.last(where: { $0.status == .pending }) {
                guard self.canTranscribe() else { break }
                await self.transcribe(next)
                if Task.isCancelled { break }
            }
            self?.worker = nil
        }
    }

    func pauseTranscription() {
        worker?.cancel()
        worker = nil
    }

    private func transcribe(_ original: CollieVoiceNote) async {
        var note = original
        note.status = .transcribing
        save(note)
        transcriber.setRecognitionTerms(terms())
        do {
            let file = try AVAudioFile(forReading: audioURL(for: note.id),
                                       commonFormat: .pcmFormatFloat32, interleaved: false)
            let total = file.length
            file.framePosition = note.transcribedFrames
            let windowFrames = AVAudioFrameCount(CollieNoteSegmenter.maxSeconds * CollieNoteSegmenter.sampleRate)
            while file.framePosition < total {
                guard !Task.isCancelled, canTranscribe() else {
                    note.status = .pending
                    save(note)
                    return
                }
                let start = file.framePosition
                guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: windowFrames)
                else { throw ColliePCMError.conversionFailed }
                try file.read(into: buffer, frameCount: windowFrames)
                let window = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
                let isFinal = start + Int64(window.count) >= total
                let keep = CollieNoteSegmenter.cutPoint(in: window, isFinal: isFinal)
                let piece = Array(window.prefix(keep))
                do {
                    let text = try await transcriber.transcribe(samples: piece)
                    note.transcript = CollieNoteSegmenter.join(note.transcript, text)
                } catch Qwen3TranscriberError.emptyTranscript {
                    // Silence: nothing to add.
                }
                note.transcribedFrames = start + Int64(keep)
                file.framePosition = note.transcribedFrames
                progress[note.id] = Double(note.transcribedFrames) / Double(max(total, 1))
                save(note)
            }
            note.status = .done
            progress[note.id] = nil
            save(note)
        } catch is CancellationError {
            note.status = .pending
            save(note)
        } catch {
            note.status = .failed
            note.failure = "转写失败，请重试。"
            progress[note.id] = nil
            save(note)
        }
    }

    /// Instruction + transcript for the share tray: short notes go in as text,
    /// long ones as an attached Markdown file plus the instruction.
    /// Returns nil on success, otherwise a message to show next to the button.
    func handOff(_ note: CollieVoiceNote, instruction: String, inbox: CollieShareInbox?) -> String? {
        guard !note.transcript.isEmpty else { return "这条记录没有识别出文字。" }
        guard let inbox else { return "无法访问一呼的共享收件箱。" }
        let body = note.transcript
        do {
            if body.count <= 3_000 {
                _ = try inbox.save(texts: ["\(instruction)\n\n\(body)"], urls: [], files: [])
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HHmm"
                let file = FileManager.default.temporaryDirectory
                    .appending(path: "语音记录 \(formatter.string(from: note.createdAt)).md")
                try "# 语音记录 \(formatter.string(from: note.createdAt))\n\n\(body)\n".write(to: file, atomically: true, encoding: .utf8)
                defer { try? FileManager.default.removeItem(at: file) }
                _ = try inbox.save(texts: [instruction + "（录音全文见附件）"], urls: [], files: [file])
            }
            return nil
        } catch {
            return error.localizedDescription
        }
    }
}
