import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gamesViewModel = GamesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                LibraryHeaderView(
                    userProfile: gamesViewModel.userProfile,
                    onLogout: {
                        authViewModel.signOut()
                    }
                )
                
                FilterBarView(gamesViewModel: gamesViewModel)
                
                if gamesViewModel.isLoading {
                    LoadingStateView()
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
    }
    
    private func loadGames() {
        guard let steamID = authViewModel.steamID else { return }
        gamesViewModel.loadGames(for: steamID)
    }
}

#Preview {
    AuthenticatedView()
        .environmentObject(AuthViewModel())
}
