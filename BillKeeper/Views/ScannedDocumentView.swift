import SwiftUI

struct ScannedDocumentView: View {
    @State var document: Document?
    @State var scan = true
    @State var currentIndex = 0
    @State private var loading = false
    @State private var uploadSuccess = false
    @State private var showAlertMessage = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        if loading {
            ProgressView("Uploading document")
                .controlSize(.large)
        } else {
            NavigationStack {
                ImageCarrouselView(document: $document, currentIndex: $currentIndex)
                .alert("Error", isPresented: $showAlertMessage) {
                    Button("OK", role: .cancel) {
                        showAlertMessage = false
                        alertMessage = ""
                    }
                } message: {
                    Text(alertMessage)
                }
                .fullScreenCover(isPresented: $scan) {
                    VNCameraView(document: $document)
                        .ignoresSafeArea()
                }
                .navigationDestination(isPresented: $uploadSuccess) {
                    UploadSuccessView()
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
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                scan.toggle()
                            }) {
                                Image(systemName: "camera")
                            }
                            .accessibilityLabel("New scan")
                        }
                    }
                }
                
                if (document != nil) {
                    VStack(spacing: 20) {
                        Button("Upload", action: {
                            uploadDocument(isBill: true)
                        })
                        .buttonStyle(BlackButton())
                        
                        Button("Upload as document", action: {
                            uploadDocument()
                        })
                    }
                }
            }
        }
    }
    
    
    func uploadDocument(isBill: Bool = false) {
        let httpClient = HttpClient()
        if document != nil {
            Task {
                do {
                    loading = true
                    if let pdfData = PDFUtils.pdfFromDocument(document: document!) {
                        try await httpClient.sendMultipartRequest(data: pdfData, filename: document?.id.uuidString ?? "", path: isBill ? "/bills" : "/documents")
                        uploadSuccess = true
                        document = nil
                    }
                    loading = false
                } catch let error as HttpError {
                    alertMessage = getAlertMessage(error: error)
                    showAlertMessage = true
                    loading = false
                }
            }
        }
    }
    
    func getAlertMessage(error: HttpError) -> String {
        let baseMessage = "Upload failed: "
        return switch error {
        case .networkError:
            baseMessage + "Network error"
        case .unknown:
            baseMessage + "Unknown error"
        case .notFound:
            baseMessage + "Not found"
        case .badRequest:
            baseMessage + "Bad request"
        case .serverError:
            baseMessage + "Server error"
        case .noInternetConnection:
            baseMessage + "No internet connection"
        case .invalidUrl:
            baseMessage + "Invalid URL"
        case .invalidData:
            baseMessage + "Invalid data"
        case .noResponse:
            baseMessage + "No response"
        case .unauthorized:
            baseMessage + "Authentication error"
        }
    }
    
}
