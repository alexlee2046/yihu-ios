@preconcurrency import AVFoundation
import CryptoKit
import Foundation
import Observation
import WatchConnectivity

private struct CollieWatchReplyCallback: @unchecked Sendable {
    var send: ([String: Any]) -> Void
}

@MainActor
@Observable
final class CollieWatchPhoneBridge: NSObject, WCSessionDelegate {
    static let shared = CollieWatchPhoneBridge()
    struct OpenRequest: Equatable { var workbench: String; var task: String; var sourceToken: String; var nonce = UUID() }
    static func sourceToken(_ workbench: CollieRadarWorkbench) -> String {
        let identity = workbench.source + "\n" + (workbench.watchSourceIdentity?.uuidString ?? "")
        return SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    static func taskToken(_ task: CollieRadarSnapshot.Action) -> String {
        let fields = [task.id ?? "", task.title, task.status ?? "", task.next]
        let data = (try? JSONEncoder().encode(fields)) ?? Data()
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
    var openRequest: OpenRequest?
    @ObservationIgnored var canReceiveDraft: () -> Bool = { false }
    @ObservationIgnored var phoneNotificationState: () -> String = { "unknown" }
    func notificationStateChanged() { publish() }
    private weak var store: CollieRadarStore?
    @ObservationIgnored var transcribeVoice: (([Float]) async throws -> String)?
    private var voiceJob: YihuWatchVoiceRequest?
    private var voiceResultFile: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WatchVoice/result.json")
    }

    func bind(_ store: CollieRadarStore) {
        self.store = store
        store.watchUpdate = { [weak self] in self?.publish() }
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func publish() {
        guard let store, WCSession.default.activationState == .activated,
              WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else { return }
        var rows: [YihuWatchSnapshot.Item] = []
        var decisions = 0
        var acceptances = 0
        for workbench in store.ordered {
            guard let snapshot = store.snapshots[workbench.id] else { continue }
            for task in snapshot.allTasks where ["等你决策", "等你验收"].contains(task.status ?? "") {
                if task.status == "等你决策" { decisions += 1 } else { acceptances += 1 }
                guard let id = task.id, !id.isEmpty else { continue }
                rows.append(.init(workbench: workbench.id.uuidString, task: id, sourceToken: Self.sourceToken(workbench), taskToken: Self.taskToken(task),
                    canDraft: workbench.supportsWatchDrafts,
                    title: String(task.title.prefix(160)), project: String(task.project.prefix(80)),
                    status: task.status ?? "", priority: task.priority ?? "", next: String(task.next.prefix(600)),
                    sourceDate: snapshot.generatedAt, readFailed: store.errors[workbench.id] != nil))
            }
        }
        var payload = YihuWatchSnapshot(items: Array(rows.prefix(200)), capturedAt: Date(),
                                        truncated: decisions + acceptances > min(rows.count, 200), hasSource: !store.snapshots.isEmpty,
            sourceDate: store.snapshots.values.contains(where: { $0.generatedAt == nil }) ? nil : store.snapshots.values.compactMap(\.generatedAt).min(),
            readFailed: !store.errors.isEmpty, phoneNotificationState: phoneNotificationState(),
            decisionCount: decisions, acceptanceCount: acceptances,
            incompleteSources: store.ordered.contains(where: { store.snapshots[$0.id] == nil || store.errors[$0.id] != nil }))
        while let data = try? JSONEncoder().encode(payload) {
            if data.count <= YihuWatchSnapshot.maximumBytes {
                try? WCSession.default.updateApplicationContext(["radar": data])
                return
            }
            guard !payload.items.isEmpty else { return }
            payload.items.removeLast(); payload.truncated = true
        }
    }

    private func receiveDraft(_ data: Data) -> String {
        guard canReceiveDraft() else { return "busy" }
        guard let store, let draft = try? YihuWatchDraft.decode(data),
              let id = UUID(uuidString: draft.workbench),
              let bench = store.workbenches.first(where: { $0.id == id }),
              bench.supportsWatchDrafts,
              Self.sourceToken(bench) == draft.sourceToken,
              let task = store.snapshots[id]?.allTasks.first(where: { $0.id == draft.task }),
              ["等你决策", "等你验收"].contains(task.status ?? ""),
              Self.taskToken(task) == draft.taskToken else { return "changed" }
        let file = CollieRadarPendingReply.file(id)
        if FileManager.default.fileExists(atPath: file.path) {
            guard let handle = try? FileHandle(forReadingFrom: file) else { return "busy" }
            defer { try? handle.close() }
            guard let bytes = try? handle.read(upToCount: 40_001), bytes.count <= 40_000,
                  let saved = try? JSONDecoder().decode(CollieRadarPendingReply.self, from: bytes),
                  saved.requestID == draft.requestID, saved.source == bench.source,
                  saved.target.id == draft.task, saved.text == draft.text else { return "busy" }
            return "saved" // Lost acknowledgement retry; never overwrite an existing draft.
        }
        do {
            let folder = file.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            var excluded = folder; var values = URLResourceValues(); values.isExcludedFromBackup = true
            try excluded.setResourceValues(values)
            let target = CollieRadarReplyTarget(eligible: false, epoch: "", id: draft.task,
                title: task.title, url: task.url, status: task.status ?? "", next: task.next, version: "")
            let record = CollieRadarPendingReply(source: bench.source, target: target, text: draft.text,
                                                requestID: draft.requestID, submitted: false)
            try JSONEncoder().encode(record).write(to: file, options: [.atomic, .completeFileProtection])
            openRequest = .init(workbench: bench.id.uuidString, task: draft.task, sourceToken: draft.sourceToken)
            return "saved"
        } catch { return "unavailable" }
    }

    private func voiceTargetMatches(_ request: YihuWatchVoiceRequest) -> Bool {
        guard let store, let id = UUID(uuidString: request.workbench),
              let bench = store.workbenches.first(where: { $0.id == id }), bench.supportsWatchDrafts,
              Self.sourceToken(bench) == request.sourceToken,
              let task = store.snapshots[id]?.allTasks.first(where: { $0.id == request.task }),
              ["等你决策", "等你验收"].contains(task.status ?? "") else { return false }
        return Self.taskToken(task) == request.taskToken
    }

    private func cachedVoiceResult() throws -> YihuWatchVoiceResult? {
        guard FileManager.default.fileExists(atPath: voiceResultFile.path) else { return nil }
        let handle = try FileHandle(forReadingFrom: voiceResultFile); defer { try? handle.close() }
        return try YihuWatchVoiceResult.decode(handle.read(upToCount: YihuWatchVoiceResult.maximumBytes + 1) ?? Data())
    }

    private func sendVoiceResult(_ result: YihuWatchVoiceResult) {
        guard let data = try? JSONEncoder().encode(result),
              (try? YihuWatchVoiceResult.decode(data)) != nil,
              WCSession.default.activationState == .activated else { return }
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["kind": "voiceResult", "result": data], replyHandler: { [weak self] response in
                let stored = response["stored"] as? Bool == true
                Task { @MainActor in
                    guard stored, let self, let cached = try? self.cachedVoiceResult(), cached == result else { return }
                    try? FileManager.default.removeItem(at: self.voiceResultFile)
                }
            }, errorHandler: { _ in /* Cached success remains available to the original-ID retry. */ })
        }
        // No polling or cloud relay; paired-device background delivery only.
        let queued = WCSession.default.outstandingUserInfoTransfers
        let duplicate = queued.contains { transfer in
            guard transfer.userInfo["kind"] as? String == "voiceResult", let bytes = transfer.userInfo["result"] as? Data else { return false }
            return (try? YihuWatchVoiceResult.decode(bytes)) == result
        }
        if !duplicate, queued.count < 4 { WCSession.default.transferUserInfo(["kind": "voiceResult", "result": data]) }
    }

    private func discardVoice(_ request: YihuWatchVoiceRequest) -> Bool {
        guard voiceJob != request else { return false }
        do {
            if let cached = try cachedVoiceResult(), cached.request == request {
                try FileManager.default.removeItem(at: voiceResultFile)
            }
            return true
        } catch { return false }
    }

    private func receiveVoice(_ request: YihuWatchVoiceRequest, audio: Data, callback: CollieWatchReplyCallback) async {
        guard voiceTargetMatches(request) else {
            callback.send(["queued": false]); sendVoiceResult(.init(request: request, outcome: .changed)); return
        }
        do {
            if let cached = try cachedVoiceResult(), cached.request.requestID == request.requestID {
                guard cached.request == request else { callback.send(["queued": false]); return }
                callback.send(["queued": true]); sendVoiceResult(cached); return
            }
        } catch { callback.send(["queued": false]); return }
        if let voiceJob { callback.send(["queued": voiceJob == request]); return }
        guard canReceiveDraft(), let transcribeVoice,
              let id = UUID(uuidString: request.workbench),
              !FileManager.default.fileExists(atPath: CollieRadarPendingReply.file(id).path) else {
            callback.send(["queued": false]); sendVoiceResult(.init(request: request, outcome: .busy)); return
        }
        voiceJob = request
        callback.send(["queued": true])
        defer { voiceJob = nil }
        let folder = voiceResultFile.deletingLastPathComponent()
        let file = folder.appendingPathComponent("audio.m4a")
        defer { try? FileManager.default.removeItem(at: file) }
        var result = YihuWatchVoiceResult(request: request, outcome: .unavailable)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            var excluded = folder; var values = URLResourceValues(); values.isExcludedFromBackup = true
            try excluded.setResourceValues(values)
            try audio.write(to: file, options: [.atomic, .completeFileProtection])
            let input = try AVAudioFile(forReading: file)
            guard input.processingFormat.sampleRate == 16_000, input.processingFormat.channelCount == 1,
                  input.length > 0, input.length <= 176_000,
                  let buffer = AVAudioPCMBuffer(pcmFormat: input.processingFormat, frameCapacity: AVAudioFrameCount(input.length))
            else { throw Qwen3TranscriberError.unsupportedAudio }
            try input.read(into: buffer)
            guard let channel = buffer.floatChannelData?.pointee else { throw Qwen3TranscriberError.unsupportedAudio }
            let samples = Array(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength)))
            guard samples.allSatisfy(\.isFinite) else { throw Qwen3TranscriberError.unsupportedAudio }
            let text = try await transcribeVoice(samples)
            guard voiceTargetMatches(request) else { sendVoiceResult(.init(request: request, outcome: .changed)); return }
            guard canReceiveDraft() else { sendVoiceResult(.init(request: request, outcome: .busy)); return }
            result = .init(request: request, outcome: .ready, text: text)
            let data = try JSONEncoder().encode(result)
            _ = try YihuWatchVoiceResult.decode(data)
            // One bounded retry receipt, never a phone reply draft or a web insertion.
            try data.write(to: voiceResultFile, options: [.atomic, .completeFileProtection])
        } catch CollieWatchVoiceError.busy { result.outcome = .busy }
        catch CollieWatchVoiceError.voiceprintBlocked { result.outcome = .voiceprintBlocked }
        catch Qwen3TranscriberError.modelMissing { result.outcome = .modelUnavailable }
        catch Qwen3TranscriberError.modelLoadFailed { result.outcome = .modelUnavailable }
        catch { result = .init(request: request, outcome: .unavailable) }
        sendVoiceResult(result)
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor [weak self] in self?.publish() }
    }
    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor [weak self] in self?.publish() }
    }
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        let kind = message["kind"] as? String
        if kind == "voice" || kind == "voiceDiscard" {
            guard let metadata = message["request"] as? Data,
                  let request = try? YihuWatchVoiceRequest.decode(metadata) else {
                replyHandler(["queued": false, "discarded": false]); return
            }
            let audio = message["audio"] as? Data
            let callback = CollieWatchReplyCallback(send: replyHandler)
            Task { @MainActor [weak self] in
                guard let self else { callback.send(["queued": false]); return }
                if kind == "voiceDiscard" { callback.send(["discarded": discardVoice(request)]); return }
                guard let audio, !audio.isEmpty, audio.count <= YihuWatchVoiceRequest.maximumAudioBytes,
                      SHA256.hash(data: audio).map({ String(format: "%02x", $0) }).joined() == request.audioDigest else {
                    callback.send(["queued": false]); return
                }
                await receiveVoice(request, audio: audio, callback: callback)
            }
            return
        }
        if kind == "draft" {
            guard let data = message["draft"] as? Data, data.count <= YihuWatchDraft.maximumBytes else {
                replyHandler(["state": "invalid"]); return
            }
            let callback = CollieWatchReplyCallback(send: replyHandler)
            Task { @MainActor [weak self] in callback.send(["state": self?.receiveDraft(data) ?? "unavailable"]) }
            return
        }
        let workbench = message["workbench"] as? String
        let task = message["task"] as? String
        let sourceToken = message["sourceToken"] as? String
        guard kind == "sync" || (kind == "open" && workbench != nil && task != nil && sourceToken != nil) else {
            replyHandler(["queued": false]); return
        }
        replyHandler(["queued": true]) // Queued, not a promise that phone UI has opened.
        Task { @MainActor [weak self] in
            guard let self else { return }
            if kind == "sync" { self.publish() }
            else if let workbench, let task, let sourceToken { self.openRequest = .init(workbench: workbench, task: task, sourceToken: sourceToken) }
        }
    }
}
