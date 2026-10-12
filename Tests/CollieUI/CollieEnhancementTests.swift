import ImageIO
import UIKit
import UniformTypeIdentifiers
import XCTest

/// Synthetic checks in the existing test target. Never opens the daily-use app,
/// camera, photo library, network, or a real App Group inbox.
@MainActor
final class CollieEnhancementTests: XCTestCase {
    private func directory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    private func fixture(width: Int = 120, height: Int = 80) throws -> CGImage {
        let context = try XCTUnwrap(CGContext(data: nil, width: width, height: height,
                                             bitsPerComponent: 8, bytesPerRow: width * 4,
                                             space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width / 2, height: height / 2))
        return try XCTUnwrap(context.makeImage())
    }
    private func encode(_ image: CGImage, orientation: Int = 1) throws -> Data {
        let data = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, [
            kCGImagePropertyOrientation: orientation,
            kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 45.0, kCGImagePropertyGPSLatitudeRef: "N"]
        ] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return data as Data
    }
    private func properties(_ data: Data) throws -> [CFString: Any] {
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        return try XCTUnwrap(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
    }

    private func cornerColors(_ data: Data) throws -> [UInt8] {
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        let width = image.width, height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        try pixels.withUnsafeMutableBytes { bytes in
            let context = try XCTUnwrap(CGContext(data: bytes.baseAddress, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return [(width / 4, height / 4), (3 * width / 4, height / 4),
                (width / 4, 3 * height / 4), (3 * width / 4, 3 * height / 4)].flatMap { x, y in
            Array(pixels[((y * width + x) * 4)..<((y * width + x) * 4 + 3)])
        }
    }

    func testNoteHandoffIsDurableAndPreservesOriginal() throws {
        let root = try directory()
        defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("note.json")
        var note = CollieVoiceNote(status: .done, transcript: "Synthetic original transcript")
        // Old saved notes have no handoff field and must continue to decode.
        let legacy = try JSONEncoder().encode(note)
        XCTAssertNil(try JSONDecoder().decode(CollieVoiceNote.self, from: legacy).handOffAttempted)
        try legacy.write(to: url)
        try note.reserveHandOff(at: url)
        var reopened = try JSONDecoder().decode(CollieVoiceNote.self, from: Data(contentsOf: url))
        XCTAssertEqual(reopened.transcript, "Synthetic original transcript")
        XCTAssertEqual(reopened.handOffAttempted, true)
        let reservedData = try Data(contentsOf: url)
        XCTAssertThrowsError(try reopened.reserveHandOff(at: url))
        XCTAssertEqual(try Data(contentsOf: url), reservedData)

        var unsaved = CollieVoiceNote(status: .done, transcript: "Still retained")
        XCTAssertThrowsError(try unsaved.reserveHandOff(at: root.appendingPathComponent("missing/note.json")))
        XCTAssertNil(unsaved.handOffAttempted)
        XCTAssertEqual(unsaved.transcript, "Still retained")
        var busy = CollieVoiceNote(status: .transcribing, transcript: "Partial")
        XCTAssertThrowsError(try busy.reserveHandOff(at: url))
    }

    func testImageBoundsAndDownsampling() async throws {
        XCTAssertFalse(CollieDiagnosticImage.validPixels(width: Int.max, height: Int.max))
        XCTAssertFalse(CollieDiagnosticImage.validPixels(width: 8_000, height: 6_000))
        XCTAssertFalse(CollieDiagnosticImage.validPixels(width: 0, height: 1))
        let root = try directory()
        defer { try? FileManager.default.removeItem(at: root) }
        let oversized = root.appendingPathComponent("large.jpg")
        FileManager.default.createFile(atPath: oversized.path, contents: nil)
        let handle = try FileHandle(forWritingTo: oversized)
        try handle.truncate(atOffset: UInt64(CollieDiagnosticImage.maximumBytes + 1))
        try handle.close()
        XCTAssertThrowsError(try CollieDiagnosticImage.read(oversized))
        let data = try encode(fixture(width: 4_096, height: 1_024))
        let jpeg = try await Task.detached { try CollieDiagnosticImage.jpeg(.encoded(data)) }.value
        let result = try properties(jpeg)
        XCTAssertEqual(result[kCGImagePropertyPixelWidth] as? Int, 2_048)
        XCTAssertEqual(result[kCGImagePropertyPixelHeight] as? Int, 512)
        XCTAssertNil(result[kCGImagePropertyGPSDictionary])
    }

    func testEveryOrientationAndScaleOne() async throws {
        let image = try fixture()
        for exif in 1...8 {
            let data = try encode(image, orientation: exif)
            let jpeg = try await Task.detached { try CollieDiagnosticImage.jpeg(.encoded(data)) }.value
            let result = try properties(jpeg)
            XCTAssertEqual(result[kCGImagePropertyPixelWidth] as? Int, exif >= 5 ? 80 : 120)
            XCTAssertEqual(result[kCGImagePropertyPixelHeight] as? Int, exif >= 5 ? 120 : 80)
            XCTAssertEqual(result[kCGImagePropertyOrientation] as? Int ?? 1, 1)
            XCTAssertNil(result[kCGImagePropertyGPSDictionary])
        }
        for orientation in [UIImage.Orientation.up, .down, .left, .right, .upMirrored, .downMirrored, .leftMirrored, .rightMirrored] {
            let raw = orientation.rawValue
            let jpeg = try await Task.detached { try CollieDiagnosticImage.jpeg(.camera(image, orientation: raw)) }.value
            let result = try properties(jpeg)
            let rotated = [.left, .right, .leftMirrored, .rightMirrored].contains(orientation)
            XCTAssertEqual(result[kCGImagePropertyPixelWidth] as? Int, rotated ? 80 : 120)
            XCTAssertEqual(result[kCGImagePropertyPixelHeight] as? Int, rotated ? 120 : 80)
            let exif: [UIImage.Orientation: Int] = [.up: 1, .upMirrored: 2, .down: 3, .downMirrored: 4,
                                                   .leftMirrored: 5, .right: 6, .rightMirrored: 7, .left: 8]
            let encoded = try encode(image, orientation: try XCTUnwrap(exif[orientation]))
            let reference = try await Task.detached { try CollieDiagnosticImage.jpeg(.encoded(encoded)) }.value
            let actualColors = try cornerColors(jpeg), expectedColors = try cornerColors(reference)
            for (actual, expected) in zip(actualColors, expectedColors) {
                XCTAssertLessThan(abs(Int(actual) - Int(expected)), 30, "Orientation must preserve corner placement")
            }
        }
    }

    func testImageCancellationAndFailurePreserveInbox() async throws {
        let root = try directory()
        defer { try? FileManager.default.removeItem(at: root) }
        let inbox = CollieShareInbox(root: root)
        let original = try inbox.save(texts: ["Existing synthetic share"], urls: [], files: [])
        do {
            _ = try await CollieDiagnosticImage.stage(.encoded(Data("not an image".utf8)), inbox: inbox)
            XCTFail("Invalid image was staged")
        } catch {}
        let image = try encode(fixture())
        let task = Task { @MainActor in try await CollieDiagnosticImage.stage(.encoded(image), inbox: inbox) }
        task.cancel()
        do { _ = try await task.value; XCTFail("Cancelled image was staged") } catch is CancellationError {} catch { XCTFail("Unexpected cancellation result") }
        XCTAssertEqual(inbox.pending(), [original])
        let added = try await CollieDiagnosticImage.stage(.encoded(image), inbox: inbox)
        XCTAssertEqual(inbox.pending().count, 2)
        XCTAssertTrue(inbox.pending().contains(original))
        XCTAssertEqual(added.items.count, 1)
        XCTAssertEqual(added.items.first?.kind, .file)
    }

    func testActivityNameIsBackwardCompatibleAndDisplayOnly() throws {
        let legacy = Data(#"{"phase":"running","startedAt":123,"sessionId":"synthetic"}"#.utf8)
        var state = try JSONDecoder().decode(HermesTaskAttributes.ContentState.self, from: legacy)
        XCTAssertEqual(state.displayTitle, "Hermes")
        state.agentName = "  Example Agent  "
        XCTAssertEqual(state.displayTitle, "Example Agent")
        XCTAssertEqual(state.phase, "running")
        XCTAssertEqual(state.sessionId, "synthetic")
        state.agentName = " \n "
        XCTAssertEqual(state.displayTitle, "Hermes")
        state.agentName = String(repeating: "A", count: 1_000)
        XCTAssertEqual(state.displayTitle.count, 80)
    }
}
