//
//  GameLibraryView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// Main screen: the user's Steam library as a searchable cover grid.
struct GameLibraryView: View {

    // @StateObject ties the view model's lifetime to this view,
    // so it survives re-renders but is created only once.
    @StateObject private var viewModel = GameLibraryViewModel()

    // SteamID saved by the login screen. Clearing it logs out.
    @AppStorage("steamID") private var steamID = ""

    // The game tapped in the grid. Drives the detail sheet.
    @State private var selectedGame: SteamGame?

    @State private var showingLogoutAlert = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Library")
                .searchable(
                    text: $viewModel.searchText,
                    prompt: "Search games"
                )
                .toolbar {
                    // Sort and filter options as a native menu, instead
                    // of the custom filter bar the original app had.
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Picker("Sort by", selection: $viewModel.selectedSort) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue)
                                }
                            }

                            Picker("Show", selection: $viewModel.selectedFilter) {
                                ForEach(FilterOption.allCases, id: \.self) { option in
                                    Text(option.rawValue)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }

                    // Picks a random game and opens its detail sheet.
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            selectedGame = viewModel.games.randomElement()
                        } label: {
                            Image(systemName: "dice")
                        }
                        .disabled(viewModel.games.isEmpty)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingLogoutAlert = true
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
                .alert("Logout", isPresented: $showingLogoutAlert) {
                    Button("Cancel", role: .cancel) { }

                    Button("Logout", role: .destructive) {
                        // Clearing the stored ID sends the app back to login.
                        steamID = ""
                    }
                } message: {
                    Text("Are you sure you want to logout?")
                }
        }
        .sheet(item: $selectedGame) { game in
            GameDetailView(game: game)
        }
        // .task runs when the view appears and is cancelled if it disappears.
        .task {
            await viewModel.loadGames(steamID: steamID)
        }
    }

    // Decides which state to show: loading, error, empty or the grid.
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading games...")
        }
        else if let message = viewModel.errorMessage {
            errorState(message: message)
        }
        else if viewModel.filteredGames.isEmpty {
            emptyState
        }
        else {
            gameGrid
        }
    }

    // LazyVGrid only builds the cards that are about to appear,
    // which keeps scrolling smooth on large libraries.
    private var gameGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredGames) { game in
                    Button {
                        selectedGame = game
                    } label: {
                        GameCardView(game: game)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadGames(steamID: steamID)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No games found",
            systemImage: "gamecontroller",
            description: Text(
                viewModel.searchText.isEmpty
                    ? "Your Steam library is empty or your profile is private."
                    : "No results for \"\(viewModel.searchText)\"."
            )
        )
    }

    private func errorState(message: String) -> some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadGames(steamID: steamID)
                }
            }
        }
    }
}

#Preview {
    GameLibraryView()
}
