import Foundation

/// Paired-device audio only; never a ledger operation or a web-composer delivery.
struct YihuWatchVoiceRequest: Codable, Equatable, Sendable {
    var version = 1
    var requestID: UUID
    var workbench: String
    var task: String
    var sourceToken: String
    var taskToken: String
    var audioDigest: String

    static let maximumBytes = 4096
    static let maximumAudioBytes = 48_000
    static let maximumDuration: TimeInterval = 10

    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CocoaError(.fileReadTooLarge) }
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard value.version == 1, UUID(uuidString: value.workbench) != nil,
              !value.task.isEmpty, value.task.utf8.count <= 160,
              [value.sourceToken, value.taskToken, value.audioDigest].allSatisfy({
                  $0.count == 64 && $0.allSatisfy { "0123456789abcdef".contains($0) }
              }) else { throw CocoaError(.fileReadCorruptFile) }
        return value
    }
}

struct YihuWatchVoiceResult: Codable, Equatable, Sendable {
    enum Outcome: String, Codable, Sendable {
        case ready, busy, changed, modelUnavailable, voiceprintBlocked, unavailable
    }
    var request: YihuWatchVoiceRequest
    var outcome: Outcome
    var text = ""

    static let maximumBytes = 24_000
    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw CocoaError(.fileReadTooLarge) }
        let result = try JSONDecoder().decode(Self.self, from: data)
        _ = try YihuWatchVoiceRequest.decode(JSONEncoder().encode(result.request))
        guard result.text.unicodeScalars.count <= 4000,
              result.outcome == .ready ? !result.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : result.text.isEmpty
        else { throw CocoaError(.fileReadCorruptFile) }
        return result
    }
}
