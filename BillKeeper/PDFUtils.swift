import PDFKit

final class PDFUtils {
    static func pdfFromDocument(document: Document) -> Data? {
        let pdfDocument = PDFDocument()
        
        document.images.forEach { page in
            let pdfPage = PDFPage(image: page)
            if (pdfPage != nil) {
                pdfDocument.insert(pdfPage!, at: pdfDocument.pageCount)
            }
        }
        return pdfDocument.dataRepresentation()
    }
}
