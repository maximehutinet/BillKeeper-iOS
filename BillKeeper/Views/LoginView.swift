import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        VStack {
            Button("Login") {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    authManager.startAuth(presenting: rootVC)
                }
            }
            .padding()
            .buttonStyle(BlackButton())
        }
        .padding()
    }
}
