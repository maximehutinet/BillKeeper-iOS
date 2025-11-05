import Foundation
import PDFKit

class FileSharingManager: ObservableObject {
    static let shared = FileSharingManager()
    
    private var sharedFileUrl: URL?
    @Published var sharedPdfFile: PDFDocument?
    
    func handleIncomingFileSharingRequest(url: URL) {
        guard let path = url.query?.removingPercentEncoding else {
            return
        }
        
        let cleanedUrl = URL(fileURLWithPath: path.replacingOccurrences(of: "file=", with: ""))
        
        guard FileManager.default.fileExists(atPath: cleanedUrl.path) else {
            return
        }
        
        self.sharedFileUrl = cleanedUrl
        
        if self.sharedFileUrl != nil {
            self.sharedPdfFile = PDFDocument(url: self.sharedFileUrl!)
        }
    }
    
    func cleanUpSharedFileUrl() throws {
        do {
            if self.sharedFileUrl == nil {
                return
            }
            try FileManager.default.removeItem(at: self.sharedFileUrl!)
            self.sharedFileUrl = nil
            self.sharedPdfFile = nil
        } catch {
            throw error
        }
    }
    
}
