import SwiftUI

@main
struct BillKeeperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.authState != nil && !authManager.isAccessTokenExpired() {
                AppView()
            } else {
                LoginView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AuthManager.shared.loadAuthState()
        if AuthManager.shared.isAccessTokenExpired() {
            Task {
                try await AuthManager.shared.refreshAccessToken()
            }
            
        }
        return true
    }
}
