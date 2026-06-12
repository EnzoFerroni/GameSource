//
//  AuthViewModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation
import Combine
import AuthenticationServices

// Handles "Sign in with Steam" using Steam's OpenID page.
// Steam only redirects to http(s) URLs, so a small static page on
// GitHub Pages receives the callback and bounces back into the app
// through the loginsteam:// custom scheme.
// NSObject is required by the presentation context protocol below.
@MainActor
final class AuthViewModel: NSObject, ObservableObject {

    @Published private(set) var isLoading = false

    // Set with a message when the login fails. nil means no error.
    @Published private(set) var errorMessage: String?

    // Where Steam sends the user back after login.
    // The page lives in this repository, at docs/index.html.
    private let callbackPage = "https://enzoferroni.github.io/GameSource-Case/"

    // Kept alive while the login web page is on screen.
    private var session: ASWebAuthenticationSession?

    // Opens Steam's login page. On success, stores the SteamID in
    // UserDefaults, which the app root observes through @AppStorage.
    func signIn() {
        isLoading = true
        errorMessage = nil

        guard let url = authURL else {
            isLoading = false
            errorMessage = "Could not build the Steam login URL."
            return
        }

        session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "loginsteam"
        ) { [weak self] callbackURL, _ in
            Task { @MainActor in
                self?.handleCallback(callbackURL)
            }
        }

        session?.presentationContextProvider = self
        session?.start()
    }

    // Steam's OpenID 2.0 login URL. identifier_select asks Steam to
    // fill in the logged user's identity on the way back.
    private var authURL: URL? {
        var components = URLComponents(string: "https://steamcommunity.com/openid/login")

        components?.queryItems = [
            URLQueryItem(name: "openid.ns", value: "http://specs.openid.net/auth/2.0"),
            URLQueryItem(name: "openid.mode", value: "checkid_setup"),
            URLQueryItem(name: "openid.return_to", value: callbackPage),
            URLQueryItem(name: "openid.realm", value: callbackPage),
            URLQueryItem(name: "openid.identity", value: "http://specs.openid.net/auth/2.0/identifier_select"),
            URLQueryItem(name: "openid.claimed_id", value: "http://specs.openid.net/auth/2.0/identifier_select")
        ]

        return components?.url
    }

    private func handleCallback(_ callbackURL: URL?) {
        isLoading = false

        guard let callbackURL,
              let steamID = extractSteamID(from: callbackURL) else {
            errorMessage = "Steam login was cancelled or failed. Try again."
            return
        }

        // Same key the views read with @AppStorage, so the app
        // switches to the library as soon as this is set.
        UserDefaults.standard.set(steamID, forKey: "steamID")
    }

    // The SteamID is the last path component of the claimed_id URL:
    // https://steamcommunity.com/openid/id/7656119...
    private func extractSteamID(from url: URL) -> String? {
        let queryItems = URLComponents(
            url: url, resolvingAgainstBaseURL: false
        )?.queryItems

        guard let claimedID = queryItems?.first(
            where: { $0.name == "openid.claimed_id" }
        )?.value else {
            return nil
        }

        return claimedID.components(separatedBy: "/").last
    }
}

// Tells the web login session which window to appear in.
extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
