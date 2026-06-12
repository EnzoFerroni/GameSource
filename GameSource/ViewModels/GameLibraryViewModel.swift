//
//  GameLibraryViewModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation
import Combine

// Holds all data and logic for the game library screen.
// The view only reads published state and forwards user actions here.
// @MainActor ensures all updates happen on the main thread,
// which SwiftUI requires when publishing changes.
@MainActor
final class GameLibraryViewModel: ObservableObject {

    // Text typed in the search field. Filtering is local because
    // the full library is already in memory after one request.
    @Published var searchText = ""

    // The games loaded from the API. Only this class can change the list.
    @Published private(set) var games: [SteamGame] = []

    // Drives the loading spinner in the view.
    @Published private(set) var isLoading = false

    // Set with a message when a request fails. nil means no error.
    @Published private(set) var errorMessage: String?

    private let service: GameFetching

    // The service can be injected so tests can pass a fake one.
    init(service: GameFetching? = nil) {
        self.service = service ?? SteamService()
    }

    // The games shown on screen, filtered by the search text.
    var filteredGames: [SteamGame] {
        guard !searchText.isEmpty else {
            return games
        }

        return games.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Loads the user's library. Used on launch, pull to refresh and retry.
    func loadGames() async {
        isLoading = true
        errorMessage = nil

        do {
            games = try await service.fetchOwnedGames()
        }
        catch {
            errorMessage = "Could not load your games. Check your connection."
        }

        isLoading = false
    }
}
