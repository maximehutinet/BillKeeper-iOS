import SwiftUI
import MobileCoreServices
import UIKit
import Social
import UniformTypeIdentifiers

struct MySwiftUIView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
    }
}

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleIncomingFile()
    }
    
    private func handleIncomingFile() {
        guard let inputItem = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        
        if let attachment = inputItem.attachments?.first {
            let typeIdentifier = "public.file-url"
            if attachment.hasItemConformingToTypeIdentifier(typeIdentifier) {
                attachment.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { data, error in
                    if let fileURL = data as? URL {
                            if let sharedURL = self.saveFileToSharedContainer(fileURL: fileURL) {
                                self.openMainApp(withFile: sharedURL)
                            }
                    }
                }
            }
        }
    }
    
    func saveFileToSharedContainer(fileURL: URL) -> URL? {
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.billkeeper") else { return nil }

        let destinationURL = sharedContainerURL.appendingPathComponent(fileURL.lastPathComponent)

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: destinationURL)
            return destinationURL
        } catch {
            return nil
        }
    }
    
    func openMainApp(withFile fileURL: URL) {
        let encodedPath = fileURL.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let url = URL(string: "billkeeper://import?file=\(encodedPath)") {
            var responder: UIResponder? = self

            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open(url, options: [:], completionHandler: nil)
                }

                responder = responder?.next
            }
        }
    }
}
