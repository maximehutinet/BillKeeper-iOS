import SwiftUI
import PDFKit

struct ScannedDocumentView: View {
    @State var scannedPdfFile: PDFDocument?
    @StateObject private var fileSharingManager = FileSharingManager.shared
    @State var showScan = false
    @State private var showAlertMessage = false
    @State private var showLogOutConfirmationDialog = false
    @State private var alertMessage: String = ""
    @StateObject private var authManager = AuthManager.shared
    @Binding var scanStatus: ScanStatus
    @State private var showBillsToSelectFrom: Bool = false
    @State private var bills: [Bill] = []
    @State private var selectedBillId: UUID? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                let fileToShow = fileSharingManager.sharedPdfFile ?? scannedPdfFile
                if fileToShow != nil {
                    PDFDocumentKitView(pdfDocument: fileToShow!)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No document to show")
                }
            }
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
                VNCameraView(pdfFile: $scannedPdfFile)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showBillsToSelectFrom, onDismiss: { selectedBillId = nil }) {
                VStack {
                    BillListView(bills: $bills, selectedBillId: $selectedBillId)
                        .presentationDetents([.medium, .large])
                    Spacer()
                    if (selectedBillId != nil) {
                        Button("Add to bill") {
                            addDocumentToBill()
                        }
                        .buttonStyle(BlackButton())
                    }
                }
                
            }
            .toolbar {
                if filePresent() {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", action: {
                            scannedPdfFile = nil
                            fileSharingManager.sharedPdfFile = nil
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
            
            if filePresent() {
                VStack(spacing: 20) {
                    Button("Create bill", action: {
                        createBill()
                    })
                    .buttonStyle(BlackButton())
                    
                    Button("Add document to bill", action: {
                        prepareAddToBillSheetData()
                    })
                }.padding(.top)
            }
        }
    }
    
    func filePresent() -> Bool {
        return scannedPdfFile != nil || fileSharingManager.sharedPdfFile != nil
    }
    
    func getCurrentFile() -> PDFDocument? {
        return fileSharingManager.sharedPdfFile ?? scannedPdfFile
    }
    
    func clearCurrentFiles() throws {
        do {
            if fileSharingManager.sharedPdfFile != nil {
                try fileSharingManager.cleanUpSharedFileUrl()
            }
            scannedPdfFile = nil
        } catch {
            throw error
        }
        
    }
    
    func prepareAddToBillSheetData() {
        let httpClient = HttpClient()
        if filePresent() {
            Task {
                do {
                    self.bills = try await httpClient.getRequest(path: "/bills") ?? [];
                    self.showBillsToSelectFrom = true
                } catch let error as HttpError {
                    alertMessage = HttpClient.getAlertMessage(error: error)
                    showAlertMessage = true
                }
            }
        }
    }
    
    func createBill() {
        let httpClient = HttpClient()
        if filePresent() {
            Task {
                do {
                    scanStatus = .uploadingScan
                    if let pdfData = getCurrentFile()?.dataRepresentation() {
                        try await httpClient.sendMultipartRequest(data: pdfData, filename: "", path: "/bills")
                        scanStatus = .scanUploaded
                        try clearCurrentFiles()
                    }
                } catch let error as HttpError {
                    alertMessage = HttpClient.getAlertMessage(error: error)
                    showAlertMessage = true
                }
            }
        }
    }
    
    func addDocumentToBill() {
        let httpClient = HttpClient()
        if filePresent() && selectedBillId != nil {
            Task {
                do {
                    scanStatus = .uploadingScan
                    if let pdfData = getCurrentFile()?.dataRepresentation() {
                        try await httpClient.sendMultipartRequest(data: pdfData, filename: "", path: "/bills/\(selectedBillId!)/documents")
                        scanStatus = .scanUploaded
                        try clearCurrentFiles()
                        selectedBillId = nil
                        showBillsToSelectFrom = false
                    }
                } catch let error as HttpError {
                    alertMessage = HttpClient.getAlertMessage(error: error)
                    showAlertMessage = true
                }
            }
        }
    }
}
