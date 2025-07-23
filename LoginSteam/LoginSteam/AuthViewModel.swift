//
//  AuthViewModel.swift
//  LoginSteam
//
//  Created by Enzo Ferroni on 23/07/25.
//

import Foundation
import AuthenticationServices

// ViewModel para tela de login
@MainActor
class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var steamID: String?
    @Published var isAuthenticated = false
    
    // Manter referência da sessão
    private var authSession: ASWebAuthenticationSession?

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func signInWithSteam() {
        // Usando httpbin.org que comprovadamente funciona
        let authURL = URL(string: "https://steamcommunity.com/openid/login?openid.ns=http://specs.openid.net/auth/2.0&openid.mode=checkid_setup&openid.return_to=https://httpbin.org/anything&openid.realm=https://httpbin.org&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select")!
        
        print("[DEBUG] Starting Steam authentication...")
        print("[DEBUG] Auth URL: \(authURL.absoluteString)")
        
        self.authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "https") { [weak self] callbackURL, error in
            print("[DEBUG] ASWebAuthenticationSession callback triggered!")
            
            if let error = error {
                print("[ERROR] Authentication error: \(error)")
                return
            }
            
            guard let callbackURL = callbackURL else {
                print("[ERROR] No callback URL received")
                return
            }
            
            print("[SUCCESS] Callback URL received: \(callbackURL.absoluteString)")
            
            if let steamID = self?.extractSteamID(from: callbackURL.absoluteString) {
                print("[SUCCESS] Steam ID extracted: \(steamID)")
                DispatchQueue.main.async {
                    self?.steamID = steamID
                    self?.isAuthenticated = true
                }
            }
        }
        
        self.authSession?.presentationContextProvider = self
        self.authSession?.prefersEphemeralWebBrowserSession = true
        self.authSession?.start()
        print("[DEBUG] ASWebAuthenticationSession started")
    }
    
    func signOut() {
        steamID = nil
        isAuthenticated = false
    }
    
    private func extractSteamID(from url: String) -> String? {
        let components = URLComponents(string: url)
        let queryItems = components?.queryItems
        
        for item in queryItems ?? [] {
            if item.name == "openid.claimed_id" {
                return item.value?.components(separatedBy: "/").last
            }
        }
        
        return nil
    }
}
