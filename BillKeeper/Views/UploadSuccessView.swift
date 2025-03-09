import SwiftUI

struct UploadSuccessView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Upload Success")
                NavigationLink("New scan", destination: ScannedDocumentView())
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
