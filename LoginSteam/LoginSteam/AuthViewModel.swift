//
//  AuthViewModel.swift
//  LoginSteam
//
//  Created by Enzo Ferroni on 23/07/25.
//

import Foundation
import AuthenticationServices

@MainActor
class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var steamID: String?
    @Published var isAuthenticated = false
    
    private var authSession: ASWebAuthenticationSession?

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func signInWithSteam() {
        let authURL = URL(string: "https://steamcommunity.com/openid/login?openid.ns=http://specs.openid.net/auth/2.0&openid.mode=checkid_setup&openid.return_to=https://enzoferroni.github.io/GameSource/&openid.realm=https://enzoferroni.github.io/GameSource/&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select")!
        
        self.authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "loginsteam") { [weak self] callbackURL, error in
            if let callbackURL = callbackURL,
               let steamID = self?.extractSteamID(from: callbackURL.absoluteString) {
                self?.steamID = steamID
                self?.isAuthenticated = true
            }
        }
        
        self.authSession?.presentationContextProvider = self
        self.authSession?.start()
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
