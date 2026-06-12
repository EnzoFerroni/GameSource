//
//  GameLibraryViewModelTests.swift
//  GameSourceTests
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Testing
@testable import GameSource

// Tests for the library screen logic: loading, search, filter and sort.
@MainActor
struct GameLibraryViewModelTests {

    private let sampleGames = [
        SteamGame(appid: 1, name: "Portal 2", playtimeForever: 600),
        SteamGame(appid: 2, name: "Celeste", playtimeForever: 0),
        SteamGame(appid: 3, name: "Hades", playtimeForever: 120)
    ]

    @Test func loadGamesFillsTheList() async {
        let viewModel = GameLibraryViewModel(
            service: FakeGameService(games: sampleGames)
        )

        await viewModel.loadGames(steamID: "123")

        #expect(viewModel.games.count == 3)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func loadGamesFailureSetsAnErrorMessage() async {
        let viewModel = GameLibraryViewModel(
            service: FakeGameService(shouldFail: true)
        )

        await viewModel.loadGames(steamID: "123")

        #expect(viewModel.games.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func searchFiltersByName() async {
        let viewModel = GameLibraryViewModel(
            service: FakeGameService(games: sampleGames)
        )
        await viewModel.loadGames(steamID: "123")

        viewModel.searchText = "cel"

        #expect(viewModel.filteredGames.map(\.name) == ["Celeste"])
    }

    @Test func playedFilterKeepsGamesWithPlaytime() async {
        let viewModel = GameLibraryViewModel(
            service: FakeGameService(games: sampleGames)
        )
        await viewModel.loadGames(steamID: "123")

        viewModel.selectedFilter = .played

        #expect(viewModel.filteredGames.map(\.name) == ["Portal 2", "Hades"])
    }

    @Test func unplayedFilterKeepsGamesWithoutPlaytime() async {
        let viewModel = GameLibraryViewModel(
            service: FakeGameService(games: sampleGames)
        )
        await viewModel.loadGames(steamID: "123")

        viewModel.selectedFilter = .unplayed

        #expect(viewModel.filteredGames.map(\.name) == ["Celeste"])
    }

    @Test func nameSortOrdersAlphabetically() async {
        let viewModel = GameLibraryViewModel(
            service: FakeGameService(games: sampleGames)
        )
        await viewModel.loadGames(steamID: "123")

        viewModel.selectedSort = .name

        #expect(viewModel.filteredGames.map(\.name) == ["Celeste", "Hades", "Portal 2"])
    }
}
