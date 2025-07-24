//
//  GamesViewModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import Foundation

@MainActor
class GamesViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var games: [SteamGame] = []
    @Published var filteredGames: [SteamGame] = []
    @Published var userProfile: SteamUserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedSort: SortOption = .playtime {
        didSet { applyFilters() }
    }
    
    @Published var selectedFilter: FilterOption = .all {
        didSet { applyFilters() }
    }
    
    @Published var searchText = "" {
        didSet { applyFilters() }
    }
    
    // MARK: - Private Properties
    
    private let steamService = SteamService()
    
    // MARK: - Public Methods
    
    func loadGames(for steamId: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedGames = try await steamService.fetchUserGames(steamId: steamId)
                let fetchedProfile = try await steamService.fetchUserProfile(steamId: steamId)
                
                games = fetchedGames
                userProfile = fetchedProfile
                applyFilters()
                isLoading = false
            } catch {
                errorMessage = "Failed to load games"
                isLoading = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func applyFilters() {
        var filtered = games
        
        // Search
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filter
        switch selectedFilter {
        case .played:
            filtered = filtered.filter { $0.playtimeForever > 0 }
        case .unplayed:
            filtered = filtered.filter { $0.playtimeForever == 0 }
        case .all:
            break
        }
        
        // Sort
        switch selectedSort {
        case .name:
            filtered = filtered.sorted { $0.name < $1.name }
        case .playtime:
            filtered = filtered.sorted { $0.playtimeForever > $1.playtimeForever }
        }
        
        filteredGames = filtered
    }
}
