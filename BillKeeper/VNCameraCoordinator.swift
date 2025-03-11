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
            let originalImage = scan.imageOfPage(at: i)
            let processedImage = ImageUtils(image: originalImage)
                .compressImage()
                .getImage()
            images.append(processedImage)
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
    
    
}
