import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gamesViewModel = GamesViewModel()
    @StateObject private var notificationService = NotificationService()
    
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
                
                // MARK: - Notification Test Section (Commented for Production)
                /*
                if !gamesViewModel.games.isEmpty {
                    HStack {
                        Button(action: {
                            testNotification()
                        }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Test Game Suggestion")
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        if !notificationService.isAuthorized {
                            Button(action: {
                                Task {
                                    await notificationService.requestPermission()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("Enable Notifications")
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                */
                
                if gamesViewModel.isLoading {
                    LoadingStateView()
                } else {
                    GameGridView(games: gamesViewModel.filteredGames)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadGames()
                setupDailyNotifications()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadGames() {
        guard let steamID = authViewModel.steamID else { return }
        gamesViewModel.loadGames(for: steamID)
    }
    
    private func setupDailyNotifications() {
        Task {
            await notificationService.requestPermission()
            
            // Schedule daily notifications at 6 PM
            if notificationService.isAuthorized && !gamesViewModel.games.isEmpty {
                notificationService.scheduleDailyGameSuggestions(from: gamesViewModel.games)
            }
        }
    }
    
    // Test method
    /*
    private func testNotification() {
        guard !gamesViewModel.games.isEmpty else {
            print("No games available for notification test")
            return
        }
        
        notificationService.scheduleRandomGameSuggestion(from: gamesViewModel.games)
    }
    */
}

#Preview {
    AuthenticatedView()
        .environmentObject(AuthViewModel())
}
