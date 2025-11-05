import VisionKit
import SwiftUI
import PDFKit

struct VNCameraView: UIViewControllerRepresentable {
    @Binding var pdfFile: PDFDocument?
    @Environment(\.dismiss) var dismiss

    typealias UIViewControllerType = VNDocumentCameraViewController

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> VNCameraCoordinator {
        VNCameraCoordinator(dismiss: dismiss, pdfFile: $pdfFile)
    }
}
