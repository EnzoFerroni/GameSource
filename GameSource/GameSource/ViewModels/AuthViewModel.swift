import Foundation
import AuthenticationServices

@MainActor
class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var steamID: String?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private var authSession: ASWebAuthenticationSession?
    private let steamAuthURL = "https://steamcommunity.com/openid/login?openid.ns=http://specs.openid.net/auth/2.0&openid.mode=checkid_setup&openid.return_to=https://enzoferroni.github.io/GameSource/&openid.realm=https://enzoferroni.github.io/GameSource/&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select"
    private let callbackScheme = "https"
        
    override init() {
        super.init()
        loadStoredCredentials()
    }
        
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
    
    func signInWithSteam() {
        isLoading = true
        
        guard let authURL = URL(string: steamAuthURL) else {
            isLoading = false
            return
        }
        
        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                self.handleAuthResponse(callbackURL: callbackURL)
            }
        }
        
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    func signOut() {
        steamID = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "steamId")
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
    }
        
    private func loadStoredCredentials() {
        guard let storedSteamID = UserDefaults.standard.string(forKey: "steamId"),
              UserDefaults.standard.bool(forKey: "isAuthenticated") else { return }
        
        steamID = storedSteamID
        isAuthenticated = true
    }
    
    private func handleAuthResponse(callbackURL: URL?) {
        guard let callbackURL = callbackURL,
              let steamID = extractSteamID(from: callbackURL.absoluteString) else { return }
        
        UserDefaults.standard.set(steamID, forKey: "steamId")
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        
        self.steamID = steamID
        self.isAuthenticated = true
    }
    
    private func extractSteamID(from url: String) -> String? {
        guard let components = URLComponents(string: url),
              let queryItems = components.queryItems else { return nil }
        
        let possibleKeys = ["openid.claimed_id", "openid.identity"]
        
        for key in possibleKeys {
            guard let value = queryItems.first(where: { $0.name == key })?.value,
                  let steamID = value.components(separatedBy: "/").last,
                  !steamID.isEmpty else { continue }
            return steamID
        }
        
        return nil
    }
}
