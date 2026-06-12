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

    @Published var selectedSort: SortOption = .playtime

    @Published var selectedFilter: FilterOption = .all

    // The games loaded from the API. Only this class can change the list.
    @Published private(set) var games: [SteamGame] = []

    // The logged user's profile, shown in the toolbar.
    @Published private(set) var userProfile: SteamUserProfile?

    // Drives the loading spinner in the view.
    @Published private(set) var isLoading = false

    // Set with a message when a request fails. nil means no error.
    @Published private(set) var errorMessage: String?

    private let service: GameFetching

    // The service can be injected so tests can pass a fake one.
    init(service: GameFetching? = nil) {
        self.service = service ?? SteamService()
    }

    // The games shown on screen: search, filter and sort applied on
    // top of the loaded list. Recomputed on every change, so there is
    // no second list to keep in sync with the original.
    var filteredGames: [SteamGame] {
        var result = games

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case .all:
            break
        case .played:
            result = result.filter { $0.playtimeForever > 0 }
        case .unplayed:
            result = result.filter { $0.playtimeForever == 0 }
        }

        switch selectedSort {
        case .playtime:
            // The service already returns most played first.
            break
        case .name:
            result = result.sorted { $0.name < $1.name }
        }

        return result
    }

    // Loads the user's library. Used on launch, pull to refresh and retry.
    // The SteamID comes from the view because the login screen owns it.
    func loadGames(steamID: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // async let starts both requests at the same time.
            // The awaits below only wait for the slower one.
            async let fetchedGames = service.fetchOwnedGames(steamID: steamID)
            async let fetchedProfile = service.fetchUserProfile(steamID: steamID)

            games = try await fetchedGames
            userProfile = try await fetchedProfile
        }
        catch {
            errorMessage = "Could not load your games. Check your connection."
        }

        isLoading = false
    }
}
