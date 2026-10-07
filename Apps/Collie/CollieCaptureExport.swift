import AVFoundation
import Foundation

/// Explicit development/test capture export. The handler is nil unless this process was launched
/// with COLLIE_CAPTURE_EXPORT=1; normal recordings are not written, uploaded, or read back.
enum CollieCaptureExport {
    // Do not use an unapplied method reference here. Xcode 27 Release fails to type-check it.
    nonisolated(unsafe) static var handler: (([Float], Bool) -> Void)? = {
        guard enabledByLaunchArgument else { return nil }
        return { samples, nearFieldEnabled in
            writeTake(samples, nearFieldEnabled: nearFieldEnabled)
        }
    }()

    static var enabledByLaunchArgument: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("COLLIE_CAPTURE_EXPORT=1")
        #else
        return false
        #endif
    }

    static func export(_ samples: [Float], nearFieldEnabled: Bool) {
        handler?(samples, nearFieldEnabled)
    }

    static func writeTake(_ samples: [Float], nearFieldEnabled: Bool) {
        guard !samples.isEmpty, samples.allSatisfy(\.isFinite),
              let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16_000, channels: 1, interleaved: false),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
              let channel = buffer.floatChannelData?[0] else { return }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { channel.update(from: $0.baseAddress!, count: samples.count) }
        let root = URL.applicationSupportDirectory.appending(path: "CaptureExport", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        var excluded = root
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try? excluded.setResourceValues(values)
        let stamp = ISO8601DateFormatter().string(from: Date())
        let url = root.appending(path: "\(stamp)-\(nearFieldEnabled)-\(UUID().uuidString).caf")
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        guard let file = try? AVAudioFile(forWriting: url, settings: format.settings, commonFormat: .pcmFormatFloat32, interleaved: false) else { return }
        try? file.write(from: buffer)
    }
}
