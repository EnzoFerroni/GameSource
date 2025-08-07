import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gamesViewModel = GamesViewModel()
    @State private var showingRandomGame = false
    @State private var randomGame: SteamGame?
    @State private var showingNotificationSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                LibraryHeaderView(
                    userProfile: gamesViewModel.userProfile,
                    onProfileTap: {
                        showingLogoutAlert = true
                    },
                    onRandomGame: {
                        selectRandomGame()
                    },
                    onNotifications: {
                        showingNotificationSettings = true
                    }
                )
                
                
                FilterBarView(gamesViewModel: gamesViewModel)
                
                if gamesViewModel.isLoading {
                    LoadingStateView()
                } else if gamesViewModel.hasNoGames {
                    EmptyStateView(onRefresh: {
                        loadGames()
                    })
                } else {
                    GameGridView(games: gamesViewModel.filteredGames, onRefresh: {
                        loadGames()
                    })
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadGames()
            }
        }
        .sheet(isPresented: Binding(
            get: { showingRandomGame },
            set: { showingRandomGame = $0 }
        )) {
            if let game = randomGame {
                GameDetailView(game: game)
            }
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView(games: gamesViewModel.allGames)
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    private func loadGames() {
        guard let steamID = authViewModel.steamID else { return }
        gamesViewModel.loadGames(for: steamID)
    }
    
    private func selectRandomGame() {
        let availableGames = gamesViewModel.allGames.isEmpty ? gamesViewModel.filteredGames : gamesViewModel.allGames
        guard !availableGames.isEmpty else { return }
        
        randomGame = availableGames.randomElement()
        showingRandomGame = true
    }
}

#Preview {
    AuthenticatedView()
        .environmentObject(AuthViewModel())
}
