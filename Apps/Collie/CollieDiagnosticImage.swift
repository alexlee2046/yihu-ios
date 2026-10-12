import Foundation
import ImageIO
import UIKit
import UniformTypeIdentifiers

/// Bounded, display-oriented JPEG staging; called only off the main thread.
enum CollieDiagnosticImage {
    static let maximumBytes = 32 * 1_048_576
    static let maximumPixels = 32_000_000
    static let maximumCameraBytes = 128 * 1_048_576
    static let maximumDimension = 2_048

    enum Failure: Error { case invalid, tooLarge }
    enum Input: Sendable {
        case encoded(Data)
        case camera(CGImage, orientation: Int)
    }

    static func validPixels(width: Int, height: Int) -> Bool {
        width > 0 && height > 0 && width <= maximumPixels / height
    }

    static func read(_ url: URL) throws -> Data {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true else { throw Failure.invalid }
        guard let size = values.fileSize, size > 0, size <= maximumBytes else { throw Failure.tooLarge }
        let file = try FileHandle(forReadingFrom: url)
        defer { try? file.close() }
        let data = try file.read(upToCount: maximumBytes + 1) ?? Data()
        guard !data.isEmpty, data.count <= maximumBytes else { throw Failure.tooLarge }
        return data
    }

    static func jpeg(_ input: Input) throws -> Data {
        precondition(!Thread.isMainThread)
        switch input {
        case .encoded(let data):
            guard !data.isEmpty, data.count <= maximumBytes else { throw Failure.tooLarge }
            guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
                  CGImageSourceGetCount(source) == 1,
                  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                  let width = properties[kCGImagePropertyPixelWidth] as? Int,
                  let height = properties[kCGImagePropertyPixelHeight] as? Int else { throw Failure.invalid }
            guard validPixels(width: width, height: height) else { throw Failure.tooLarge }
            guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maximumDimension,
                kCGImageSourceShouldCacheImmediately: true
            ] as CFDictionary) else { throw Failure.invalid }
            return try encode(image)
        case .camera(let image, let rawOrientation):
            // UIImagePicker owns the original camera bitmap. Validate its actual
            // storage before allocating another bitmap; never use screen scale.
            guard validPixels(width: image.width, height: image.height),
                  image.bytesPerRow <= maximumCameraBytes / image.height else { throw Failure.tooLarge }
            guard let orientation = UIImage.Orientation(rawValue: rawOrientation) else { throw Failure.invalid }
            let rotated = [.left, .leftMirrored, .right, .rightMirrored].contains(orientation)
            let width = rotated ? image.height : image.width
            let height = rotated ? image.width : image.height
            let ratio = min(1, Double(maximumDimension) / Double(max(width, height)))
            let size = CGSize(width: max(1, floor(Double(width) * ratio)),
                              height: max(1, floor(Double(height) * ratio)))
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            format.preferredRange = .standard
            let resized = UIGraphicsImageRenderer(size: size, format: format).image { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: size))
                UIImage(cgImage: image, scale: 1, orientation: orientation).draw(in: CGRect(origin: .zero, size: size))
            }
            guard let output = resized.cgImage else { throw Failure.invalid }
            return try encode(output)
        }
    }

    /// Admission/cancellation and the short inbox commit run on the main actor;
    /// expensive decoding/drawing is detached. Cancellation cannot interleave
    /// between the final check and the atomic inbox save.
    @MainActor
    static func stage(_ input: Input, inbox: CollieShareInbox) async throws -> CollieShareBatch {
        try Task.checkCancellation()
        let data = try await Task.detached(priority: .userInitiated) { try jpeg(input) }.value
        try Task.checkCancellation()
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        defer { try? FileManager.default.removeItem(at: file) }
        try data.write(to: file, options: [.atomic, .completeFileProtection])
        return try inbox.save(texts: [], urls: [], files: [file])
    }

    private static func encode(_ image: CGImage) throws -> Data {
        guard image.width <= maximumDimension, image.height <= maximumDimension else { throw Failure.tooLarge }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        else { throw Failure.invalid }
        // Only pixels and encoding quality are copied, not GPS or source metadata.
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
        guard CGImageDestinationFinalize(destination), data.length <= maximumBytes else { throw Failure.invalid }
        return data as Data
    }
}
