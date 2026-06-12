//
//  GameDetailViewModelTests.swift
//  GameSourceTests
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation
import Testing
@testable import GameSource

// Tests for the detail screen logic: merging progress with icons,
// sorting and the completion percentage.
@MainActor
struct GameDetailViewModelTests {

    private let progress = [
        SteamAchievement(
            apiname: "ACH_WIN",
            achieved: 1,
            unlocktime: 1_700_000_000,
            name: "First Win",
            description: "Win a match."
        ),
        SteamAchievement(
            apiname: "ACH_LOSE",
            achieved: 0,
            unlocktime: 0,
            name: "First Loss",
            description: nil
        )
    ]

    private let schemas = [
        AchievementSchema(
            name: "ACH_WIN",
            icon: "https://example.com/win.jpg",
            icongray: "https://example.com/win_gray.jpg"
        ),
        AchievementSchema(
            name: "ACH_LOSE",
            icon: "https://example.com/lose.jpg",
            icongray: "https://example.com/lose_gray.jpg"
        )
    ]

    @Test func unlockedAchievementGetsTheColoredIcon() async {
        let viewModel = GameDetailViewModel(
            service: FakeGameService(achievements: progress, schemas: schemas)
        )

        await viewModel.loadAchievements(steamID: "123", appId: 1)

        let unlocked = viewModel.achievements.first { $0.id == "ACH_WIN" }
        #expect(unlocked?.iconURL?.absoluteString == "https://example.com/win.jpg")
    }

    @Test func lockedAchievementGetsTheGrayIcon() async {
        let viewModel = GameDetailViewModel(
            service: FakeGameService(achievements: progress, schemas: schemas)
        )

        await viewModel.loadAchievements(steamID: "123", appId: 1)

        let locked = viewModel.achievements.first { $0.id == "ACH_LOSE" }
        #expect(locked?.iconURL?.absoluteString == "https://example.com/lose_gray.jpg")
        #expect(locked?.unlockDate == nil)
    }

    @Test func unlockedAchievementsComeFirst() async {
        let viewModel = GameDetailViewModel(
            service: FakeGameService(achievements: progress, schemas: schemas)
        )

        await viewModel.loadAchievements(steamID: "123", appId: 1)

        #expect(viewModel.achievements.first?.id == "ACH_WIN")
        #expect(viewModel.achievements.first?.isUnlocked == true)
    }

    @Test func completionIsTheUnlockedFraction() async {
        let viewModel = GameDetailViewModel(
            service: FakeGameService(achievements: progress, schemas: schemas)
        )

        await viewModel.loadAchievements(steamID: "123", appId: 1)

        #expect(viewModel.unlockedCount == 1)
        #expect(viewModel.completion == 0.5)
    }

    @Test func completionIsZeroWithoutAchievements() {
        let viewModel = GameDetailViewModel(service: FakeGameService())

        #expect(viewModel.completion == 0)
    }
}
