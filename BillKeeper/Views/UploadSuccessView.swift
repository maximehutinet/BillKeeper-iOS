import SwiftUI

struct UploadSuccessView: View {
    @Binding var scanStatus: ScanStatus
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Upload Success")
                Button("New scan") {
                    scanStatus = .waitingForScan
                }
                .buttonStyle(BlackButton())
            }
        }
        .onAppear() {
            triggerSuccessHaptic()
        }
    }
    
    func triggerSuccessHaptic() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
    }
}
