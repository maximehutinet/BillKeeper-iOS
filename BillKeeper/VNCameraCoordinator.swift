import VisionKit
import SwiftUI
import PDFKit

final class VNCameraCoordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    @Binding var pdfFile: PDFDocument?
    var dismiss : DismissAction
    
    init(dismiss: DismissAction, pdfFile: Binding<PDFDocument?>) {
        self.dismiss = dismiss
        self._pdfFile = pdfFile
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let pdfDocument = PDFDocument()
        for i in 0..<scan.pageCount {
            let originalImage = scan.imageOfPage(at: i)
            let processedImage = ImageUtils(image: originalImage)
                .compressImage()
                .getImage()
            let pdfPage = PDFPage(image: processedImage)
            if (pdfPage != nil) {
                pdfDocument.insert(pdfPage!, at: pdfDocument.pageCount)
            }
        }
        pdfFile = pdfDocument
        dismiss()
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss()
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        dismiss()
    }
    
    
}
