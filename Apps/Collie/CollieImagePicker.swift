import CoreTransferable
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ColliePhotoInput: Transferable, Sendable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            let url = received.file
            let data = try await Task.detached(priority: .userInitiated) {
                try CollieDiagnosticImage.read(url)
            }.value
            return ColliePhotoInput(data: data)
        }
    }
}

/// Camera access is requested explicitly by the caller, never on app launch.
struct CollieCameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImageCaptured: @MainActor (CollieDiagnosticImage.Input) -> Void
    var onFailure: @MainActor () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return UIViewController() }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ controller: UIViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    @MainActor
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CollieCameraPicker
        private var finished = false
        init(_ parent: CollieCameraPicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard !finished else { return }
            finished = true
            if let image = info[.originalImage] as? UIImage, let bitmap = image.cgImage {
                parent.onImageCaptured(.camera(bitmap, orientation: image.imageOrientation.rawValue))
            } else { parent.onFailure() }
            parent.isPresented = false
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            finished = true
            parent.isPresented = false
        }
    }
}
