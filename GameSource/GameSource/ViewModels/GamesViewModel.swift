import Foundation

@MainActor
class GamesViewModel: ObservableObject {
    @Published var games: [SteamGame] = []
    @Published var filteredGames: [SteamGame] = []
    @Published var userProfile: SteamUserProfile?
    @Published var isLoading = false
    @Published var selectedSort: SortOption = .playtime {
        didSet { applyFilters() }
    }
    @Published var selectedFilter: FilterOption = .all {
        didSet { applyFilters() }
    }
    @Published var searchText = "" {
        didSet { applyFilters() }
    }
    
    var allGames: [SteamGame] {
        return games
    }
    
    private let steamService = SteamService()
    
    func loadGames(for steamId: String) {
        isLoading = true
        
        Task {
            let fetchedGames = await steamService.fetchUserGames(steamId: steamId)
            let fetchedProfile = await steamService.fetchUserProfile(steamId: steamId)
            
            games = fetchedGames
            userProfile = fetchedProfile
            applyFilters()
            isLoading = false
        }
    }
    
    private func applyFilters() {
        var filtered = games
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch selectedFilter {
        case .played:
            filtered = filtered.filter { $0.playtimeForever > 0 }
        case .unplayed:
            filtered = filtered.filter { $0.playtimeForever == 0 }
        case .all:
            break
        }
        
        switch selectedSort {
        case .name:
            filtered = filtered.sorted { $0.name < $1.name }
        case .playtime:
            filtered = filtered.sorted { $0.playtimeForever > $1.playtimeForever }
        }
        
        filteredGames = filtered
    }
}
