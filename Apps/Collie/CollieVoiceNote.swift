import Foundation

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
    /// Reserved durably before any handoff; uncertain results are never retried automatically.
    var handOffAttempted: Bool? = nil

    enum HandoffError: Error { case unavailable }

    mutating func reserveHandOff(at url: URL) throws {
        guard status == .done, !transcript.isEmpty, handOffAttempted != true else {
            throw HandoffError.unavailable
        }
        var reserved = self
        reserved.handOffAttempted = true
        let data = try JSONEncoder().encode(reserved)
        // Preserve the existing note store's file-protection/read lifecycle.
        try data.write(to: url, options: .atomic)
        self = reserved
    }
}
