import Foundation

// MARK: - Steam Achievements Response

struct SteamAchievementsResponse: Codable {
    let playerstats: PlayerStats
}

struct PlayerStats: Codable {
    let steamID: String
    let gameName: String
    let achievements: [SteamAchievement]?
    
    enum CodingKeys: String, CodingKey {
        case steamID = "steamID"
        case gameName = "gameName"
        case achievements
    }
}

// MARK: - Steam Achievement Model

struct SteamAchievement: Codable, Identifiable {
    let apiname: String
    let achieved: Int
    let unlocktime: Int
    let name: String?
    let description: String?
    
    var id: String {
        apiname
    }
    
    var isUnlocked: Bool {
        achieved == 1
    }
    
    var unlockDate: Date? {
        guard unlocktime > 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(unlocktime))
    }
}

// MARK: - Achievement Stats Summary

struct AchievementStats {
    let totalAchievements: Int
    let unlockedAchievements: Int
    let completionPercentage: Double
    
    var formattedCompletion: String {
        return String(format: "%.1f%%", completionPercentage)
    }
}