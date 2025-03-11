import SwiftUI

enum ScanStatus {
    case waitingForScan
    case uploadingScan
    case scanUploaded
}

struct AppView: View {
    @State private var scanStatus: ScanStatus = .waitingForScan
    
    var body: some View {
        switch scanStatus {
        case .waitingForScan:
            ScannedDocumentView(scanStatus: $scanStatus)
        case .uploadingScan:
            ProgressView("Uploading to server")
                .controlSize(.large)
        case .scanUploaded:
            UploadSuccessView(scanStatus: $scanStatus)
        }
    }
}
