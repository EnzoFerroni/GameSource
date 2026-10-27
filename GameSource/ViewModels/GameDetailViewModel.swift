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

    @Published private(set) var achievements: [GameAchievement] = []

    @Published private(set) var isLoading = false

    private let service: GameFetching

    // The service can be injected so tests can pass a fake one.
    init(service: GameFetching? = nil) {
        self.service = service ?? SteamService()
    }

    var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    // Fraction of unlocked achievements, 0...1, for the progress bar.
    var completion: Double {
        guard !achievements.isEmpty else {
            return 0
        }

        return Double(unlockedCount) / Double(achievements.count)
    }

    // Loads the achievements for one game. A failure here only means
    // the section shows as empty, so the screen stays usable.
    func loadAchievements(steamID: String, appId: Int) async {
        isLoading = true

        // The player's progress and the game's icons come from two
        // endpoints; async let fetches both in parallel.
        async let fetchedProgress = service.fetchAchievements(
            steamID: steamID, appId: appId
        )
        async let fetchedSchemas = service.fetchAchievementSchemas(
            appId: appId
        )

        let progress = (try? await fetchedProgress) ?? []
        let schemas = (try? await fetchedSchemas) ?? []

        achievements = merge(progress, with: schemas)
        isLoading = false
    }

    // Joins the two responses into the display model the view reads.
    private func merge(_ progress: [SteamAchievement], with schemas: [AchievementSchema]) -> [GameAchievement] {
        // A dictionary makes finding each icon instant, instead of
        // searching the whole list once per achievement.
        let schemaByName = Dictionary(
            schemas.map { ($0.name, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        return progress.map { achievement in
            let schema = schemaByName[achievement.apiname]
            let isUnlocked = achievement.achieved == 1

            // Steam ships a gray version of every icon for locked ones.
            let icon = isUnlocked ? schema?.icon : schema?.icongray

            return GameAchievement(
                id: achievement.apiname,
                name: achievement.name,
                description: achievement.description,
                isUnlocked: isUnlocked,
                unlockDate: achievement.unlocktime > 0 ? Date(timeIntervalSince1970: TimeInterval(achievement.unlocktime)): nil,
                iconURL: icon.flatMap(URL.init)
            )
        }
        .sorted { lhs, rhs in
            // Most recent unlocks first. Locked ones keep Steam's order.
            switch (lhs.unlockDate, rhs.unlockDate) {
            case let (left?, right?):
                return left > right
            case (.some, nil):
                return true
            default:
                return false
            }
        }
    }
}
