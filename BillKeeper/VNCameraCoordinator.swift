import VisionKit
import SwiftUI

final class VNCameraCoordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    @Binding var document: Document?
    var dismiss : DismissAction
    
    init(dismiss: DismissAction, document: Binding<Document?>) {
        self._document = document
        self.dismiss = dismiss
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images: [UIImage] = []
        for i in 0..<scan.pageCount {
            let image = makeImageOpaque(image: scan.imageOfPage(at: i))
            images.append(image)
        }
        document = Document(images: images)
        dismiss()
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss()
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        dismiss()
    }
    
    func makeImageOpaque(image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
