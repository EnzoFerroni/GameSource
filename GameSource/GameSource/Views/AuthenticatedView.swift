//
//  AuthenticatedView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gamesViewModel = GamesViewModel()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Library")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if let userProfile = gamesViewModel.userProfile {
                            AsyncImage(url: URL(string: userProfile.avatarmedium)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        }
                        
                        Button("Logout") {
                            authViewModel.signOut()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                
                FilterBarView(gamesViewModel: gamesViewModel)
                
                if gamesViewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if let errorMessage = gamesViewModel.errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                        Button("Try Again") {
                            loadGames()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(gamesViewModel.filteredGames) { game in
                                VStack {
                                    SteamImageView(appid: game.appid)
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                    
                                    Text(game.name)
                                        .font(.caption)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding()
                    }
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
