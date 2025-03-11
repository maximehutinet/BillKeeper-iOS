import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var showAlertMessage: Bool = false
    @State private var authPending: Bool = false

    var body: some View {
        VStack {
            Button("Login") {
                authPending = true
                startAuth()
            }
            .padding()
            .buttonStyle(BlackButton(isLoading: authPending))
        }
        .alert(isPresented: $showAlertMessage) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                showAlertMessage = false
                alertMessage = ""
            }))
        }
        .padding()
    }
    
    private func startAuth() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            authManager.startAuth(presenting: rootVC) { result in
                authPending = false
                if case .failure(let failure) = result {
                    alertTitle = "Login failed"
                    alertMessage = getAlertMessage(error: failure)
                    showAlertMessage = true
                }
            }
        }
    }
    
    private func getAlertMessage(error: AuthError) -> String {
        switch error {
        case AuthError.authorizationFailed(let reason):
            return reason
        case AuthError.noAuthState:
            return "Couldn't create auth state."
        case AuthError.noConfiguration(let reason):
            return "Couldn't get configurations from server.\n \(reason)"
        default:
            return "Unknown error"
        }
    }
}
