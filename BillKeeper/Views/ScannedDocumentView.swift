import SwiftUI

struct ScannedDocumentView: View {
    @State var document: Document?
    @State var showScan = true
    @State private var showAlertMessage = false
    @State private var showLogOutConfirmationDialog = false
    @State private var alertMessage: String = ""
    @StateObject private var authManager = AuthManager.shared
    @Binding var scanStatus: ScanStatus
    
    var body: some View {
        NavigationStack {
            ImageCarrouselView(document: $document)
                .alert("Error", isPresented: $showAlertMessage) {
                    Button("OK", role: .cancel) {
                        showAlertMessage = false
                        alertMessage = ""
                    }
                } message: {
                    Text(alertMessage)
                }
                .confirmationDialog(
                    "Do you really want to log out",
                    isPresented: $showLogOutConfirmationDialog,
                    titleVisibility: .visible
                ) {
                    Button("Cancel", role: .cancel) {
                        showLogOutConfirmationDialog = false
                    }
                    Button("OK", role: .destructive) {
                        authManager.logout()
                        showLogOutConfirmationDialog = false
                    }
                }
                .fullScreenCover(isPresented: $showScan) {
                    VNCameraView(document: $document)
                        .ignoresSafeArea()
                }
                .toolbar {
                    if document != nil {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel", action: {
                                document = nil
                            })
                            .accessibilityLabel("Cancel")
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showLogOutConfirmationDialog = true
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                            .accessibilityLabel("Log out")
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showScan.toggle()
                            }) {
                                Image(systemName: "camera")
                            }
                            .accessibilityLabel("New scan")
                        }
                    }
                }
            
            if (document != nil) {
                VStack(spacing: 20) {
                    Button("Create bill", action: {
                        uploadDocument(isBill: true)
                    })
                    .buttonStyle(BlackButton())
                    
                    Button("Create document", action: {
                        uploadDocument()
                    })
                }
            }
        }
    }
    
    func uploadDocument(isBill: Bool = false) {
        let httpClient = HttpClient()
        if document != nil {
            Task {
                do {
                    scanStatus = .uploadingScan
                    if let pdfData = PDFUtils.pdfFromDocument(document: document!) {
                        try await httpClient.sendMultipartRequest(data: pdfData, filename: document?.id.uuidString ?? "", path: isBill ? "/bills" : "/documents")
                        scanStatus = .scanUploaded
                        document = nil
                    }
                } catch let error as HttpError {
                    alertMessage = HttpClient.getAlertMessage(error: error)
                    showAlertMessage = true
                }
            }
        }
    }
}
