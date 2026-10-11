import PhotosUI
import SwiftUI
import UIKit

/// Native camera capture sheet for instant diagnostic photos (screen errors, paper sketches).
struct CollieCameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImageCaptured: @MainActor (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CollieCameraPicker

        init(_ parent: CollieCameraPicker) {
            self.parent = parent
        }

        @MainActor
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.isPresented = false
        }

        @MainActor
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
