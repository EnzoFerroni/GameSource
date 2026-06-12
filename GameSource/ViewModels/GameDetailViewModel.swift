//
//  GameDetailViewModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation
import Combine

// Holds the achievements shown on the detail screen.
// Separate from the library view model so each screen owns its state.
@MainActor
final class GameDetailViewModel: ObservableObject {

    @Published private(set) var achievements: [SteamAchievement] = []

    @Published private(set) var isLoading = false

    private let service: GameFetching

    // The service can be injected so tests can pass a fake one.
    init(service: GameFetching? = nil) {
        self.service = service ?? SteamService()
    }

    var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    // Loads the achievements for one game. A failure here only means
    // the section shows as empty, so the screen stays usable.
    func loadAchievements(steamID: String, appId: Int) async {
        isLoading = true

        achievements = (try? await service.fetchAchievements(
            steamID: steamID,
            appId: appId
        )) ?? []

        isLoading = false
    }
}
