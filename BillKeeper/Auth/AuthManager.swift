import AppAuth

enum AuthError: Error {
    case authorizationFailed(reason: String)
    case noAuthState
    case noConfiguration(reason: String)
    case refreshFailed
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var authState: OIDAuthState?
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    private var configuration: OIDServiceConfiguration?
    
    private let keycloakIssuerUrl: URL? = BundleUtils.getBundleValue(key: "KeycloakIssuerUrl")
    private let keycloakClientId: String? = BundleUtils.getBundleValue(key: "KeycloakClientId")
    private let keycloakRedirectURI: URL? = BundleUtils.getBundleValue(key: "KeycloakRedirectURI")
    private let scopes = ["openid", "profile", "email"]
    private let keychainService = "com.billkeeper.auth"
    private let keychainAccount = "authState"
    
    private init() {
        discoverConfiguration() {_ in }
    }
    
    func keycloakVariablesAreSet() -> Bool {
        guard let issuerUrl = keycloakIssuerUrl,
              let clientId = keycloakClientId, !clientId.isEmpty,
              let redirectUri = keycloakRedirectURI else {
            return false
        }
        return true
    }
    
    func discoverConfiguration(failure: @escaping (Error?) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: keycloakIssuerUrl!) { configuration, error in
            if let error = error {
                failure(error)
                return
            }
            if let config = configuration {
                self.configuration = config
            }
        }
    }
    
    func startAuth(presenting viewController: UIViewController, completion: @escaping (Result<OIDAuthState, AuthError>) -> Void) {
        if !keycloakVariablesAreSet() {
            completion(.failure(AuthError.noConfiguration(reason: "Info.plist not set properly")))
        }
        
        guard let config = configuration else {
            discoverConfiguration() { failure in
                if failure != nil {
                    completion(.failure(AuthError.noConfiguration(reason: failure!.localizedDescription)))
                    return
                }
            }
            return
        }
        
        let request = OIDAuthorizationRequest(
            configuration: config,
            clientId: keycloakClientId!,
            scopes: scopes,
            redirectURL: keycloakRedirectURI!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )

        currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            presenting: viewController
        ) { authState, error in
            if error != nil {
                completion(.failure(AuthError.authorizationFailed(reason: error!.localizedDescription)))
                return
            }
            
            if let authState = authState {
                self.authState = authState
                self.storeAuthState()
                completion(.success(authState))
            } else {
                completion(.failure(AuthError.noAuthState))
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
