import Foundation

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
    
    var formattedUnlockDate: String? {
        guard let date = unlockDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var displayName: String {
        return name ?? "Secret Achievement"
    }
    
    var displayDescription: String {
        return description ?? "This achievement is hidden"
    }
}

struct AchievementSchemaResponse: Codable {
    let game: GameSchema?
}

struct GameSchema: Codable {
    let gameName: String?
    let gameVersion: String?
    let availableGameStats: AvailableGameStats?
}

struct AvailableGameStats: Codable {
    let achievements: [AchievementSchema]?
}

struct AchievementSchema: Codable {
    let name: String
    let defaultvalue: Int?
    let displayName: String?
    let hidden: Int?
    let description: String?
    let icon: String?
    let icongray: String?
}
