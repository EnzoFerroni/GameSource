//
//  AuthViewModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import Foundation
import AuthenticationServices

@MainActor
class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var steamID: String?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authSession: ASWebAuthenticationSession?
    private let steamAuthURL = "https://steamcommunity.com/openid/login?openid.ns=http://specs.openid.net/auth/2.0&openid.mode=checkid_setup&openid.return_to=https://enzoferroni.github.io/GameSource/&openid.realm=https://enzoferroni.github.io/GameSource/&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select"
    private let callbackScheme = "https"
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func signInWithSteam() {
        isLoading = true
        errorMessage = nil
        
        guard let authURL = URL(string: steamAuthURL) else {
            errorMessage = "Invalid authentication URL"
            isLoading = false
            return
        }
        
        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                self.handleAuthResponse(callbackURL: callbackURL, error: error)
            }
        }
        
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    func signOut() {
        steamID = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    func dismissError() {
        errorMessage = nil
    }
    
    private func handleAuthResponse(callbackURL: URL?, error: Error?) {
        if error != nil {
            errorMessage = "Authentication failed"
            return
        }
        
        guard let callbackURL = callbackURL else {
            errorMessage = "No callback URL received"
            return
        }
        
        guard let steamID = extractSteamID(from: callbackURL.absoluteString) else {
            errorMessage = "Failed to extract Steam ID"
            return
        }
        
        self.steamID = steamID
        self.isAuthenticated = true
    }
    
    private func extractSteamID(from url: String) -> String? {
        guard let components = URLComponents(string: url),
              let queryItems = components.queryItems else {
            return nil
        }
        
        let possibleKeys = ["openid.claimed_id", "openid.identity"]
        
        for key in possibleKeys {
            if let value = queryItems.first(where: { $0.name == key })?.value {
                if let steamID = value.components(separatedBy: "/").last, !steamID.isEmpty {
                    return steamID
                }
            }
        }
        
        return nil
    }
}
