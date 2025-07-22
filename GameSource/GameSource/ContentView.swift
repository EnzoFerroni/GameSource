//
//  ContentView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - Environment Properties
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - State Properties
    @StateObject private var gamesViewModel = GamesViewModel()
    @State private var selectedGame: Game?
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            libraryTab
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Biblioteca")
                }
                .tag(0)
            
            playLaterTab
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lista")
                }
                .tag(1)
        }
        .accentColor(.accentBlue)
        .preferredColorScheme(.dark)
        .onAppear {
            gamesViewModel.setContext(viewContext)
            if gamesViewModel.games.isEmpty {
                Task {
                    await gamesViewModel.loadGames()
                }
            }
        }
        .sheet(item: $selectedGame) { game in
            GameDetailView(
                game: game,
                isPresented: .constant(true),
                viewModel: gamesViewModel
            )
        }
        .alert("Error", isPresented: .constant(gamesViewModel.errorMessage != nil)) {
            Button("OK") {
                gamesViewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = gamesViewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Library Tab
    private var libraryTab: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                if gamesViewModel.games.isEmpty && !gamesViewModel.isLoading {
                    emptyStateView
                } else {
                    libraryContent
                }
            }
            .navigationTitle("Biblioteca")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            Task {
                                await gamesViewModel.loadGames()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.accentBlue)
                        }
                        
                        Menu {
                            Button("Load Games") {
                                Task {
                                    await gamesViewModel.loadGames()
                                }
                            }
                            Button("Clear Library") {
                                gamesViewModel.clearAllGames()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.accentBlue)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Play Later Tab
    private var playLaterTab: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                if gamesViewModel.favoriteGames.isEmpty {
                    playLaterEmptyState
                } else {
                    playLaterContent
                }
            }
            .navigationTitle("Jogar Depois")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Library Content
    private var libraryContent: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 20) {
                ForEach(gamesViewModel.games, id: \.objectID) { game in
                    GameCardView(game: game, selectedGame: $selectedGame)
                }
            }
            .padding()
        }
        .refreshable {
            await gamesViewModel.loadGames()
        }
    }
    
    // MARK: - Play Later Content
    private var playLaterContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gamesViewModel.favoriteGames, id: \.objectID) { game in
                    HStack {
                        AsyncImage(url: URL(string: game.headerImage ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.secondaryBackground)
                                .overlay(
                                    Image(systemName: "gamecontroller.fill")
                                        .foregroundColor(.mediumGray)
                                )
                        }
                        .frame(width: 60, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        Text(game.name ?? "Unknown Game")
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Button(action: {
                            gamesViewModel.deleteGame(game)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.mediumGray)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        selectedGame = game
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty States
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 60))
                .foregroundColor(.mediumGray)
            
            Text("Sua biblioteca está vazia")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Toque no botão abaixo para carregar jogos da Steam")
                .font(.body)
                .foregroundColor(.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await gamesViewModel.loadGames()
                }
            }) {
                HStack {
                    if gamesViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                    }
                    Text(gamesViewModel.isLoading ? "Carregando..." : "Carregar Jogos")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(gamesViewModel.isLoading)
        }
    }
    
    private var playLaterEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.mediumGray)
            
            Text("Nenhum jogo favoritado")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Favorite jogos na biblioteca para vê-los aqui")
                .font(.body)
                .foregroundColor(.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
