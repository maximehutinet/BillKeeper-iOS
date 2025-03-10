import AppAuth

enum AuthError: Error {
    case noAuthState
    case refreshFailed
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var authState: OIDAuthState?
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    private var configuration: OIDServiceConfiguration?
    
    private let keycloakIssuerURL = URL(string: "http://10.0.0.23:10493/realms/billkeeper")!
    private let keycloakClientID = "billkeeper-ios"
    private let redirectURI = URL(string: "com.billkeeper.app:/oauth2redirect/provider")!
    private let scopes = ["openid", "profile", "email"]
    private let keychainService = "com.billkeeper.auth"
    private let keychainAccount = "authState"
    
    private init() {
        discoverConfiguration()
    }
    
    func discoverConfiguration() {
        OIDAuthorizationService.discoverConfiguration(forIssuer: keycloakIssuerURL) { configuration, error in
            if let config = configuration {
                self.configuration = config
            }
        }
    }
    
    func startAuth(presenting viewController: UIViewController) {
        guard let config = configuration else {
            discoverConfiguration()
            return
        }
        
        let request = OIDAuthorizationRequest(
            configuration: config,
            clientId: keycloakClientID,
            scopes: scopes,
            redirectURL: redirectURI,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )
        
        currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            presenting: viewController
        ) { authState, error in
            if let state = authState {
                self.authState = state
                self.storeAuthState()
            }
        }
    }
    
    func storeAuthState() {
        if (authState != nil) {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: authState!, requiringSecureCoding: true) {
                KeychainHelper.shared.storeData(data: data, service: keychainService, account: keychainAccount)
            }
        }
    }
    
    func loadAuthState() {
        if let data = KeychainHelper.shared.readData(service: keychainService, account: keychainAccount) {
            if let state = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
                authState = state
            }
        }
    }
    
    func getAccessToken() async -> String? {
        if isAccessTokenExpired() {
            try? await refreshAccessToken()
        }
        return authState?.lastTokenResponse?.accessToken;
    }
    
    func refreshAccessToken() async throws {
        if authState == nil {
            throw AuthError.noAuthState
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.authState!.performAction { token, _, error in
                if error != nil {
                    continuation.resume(throwing: AuthError.refreshFailed)
                    return
                }
                
                if token != nil {
                    self.storeAuthState()
                    continuation.resume()
                } else {
                    continuation.resume(throwing: AuthError.refreshFailed)
                }
            }
        }
    }
    
    func isAccessTokenExpired() -> Bool {
        if authState == nil {
            return true
        }
        
        guard let expirationDate = authState!.lastTokenResponse?.accessTokenExpirationDate else {
                return true
        }
        return Date() >= expirationDate
    }
    
    func isLoggedIn() -> Bool {
        return !isAccessTokenExpired()
    }

    func logout() {
        KeychainHelper.shared.deleteData(service: keychainService, account: keychainAccount)
        authState = nil
    }
}
