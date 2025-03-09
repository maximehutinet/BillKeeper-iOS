import VisionKit
import SwiftUI

struct VNCameraView: UIViewControllerRepresentable {
    @Binding var document: Document?
    @Environment(\.dismiss) var dismiss

    typealias UIViewControllerType = VNDocumentCameraViewController

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> VNCameraCoordinator {
        VNCameraCoordinator(dismiss: dismiss, document: $document)
    }
}
