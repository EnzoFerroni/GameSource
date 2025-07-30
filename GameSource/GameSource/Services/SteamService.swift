import Foundation

class SteamService {
    private let baseUrl = "https://api.steampowered.com"
    private let apiKey = APIConfiguration.shared.steamAPIKey
    
    func fetchUserGames(steamId: String) async -> [SteamGame] {
        let urlString = "\(baseUrl)/IPlayerService/GetOwnedGames/v0001/?key=\(apiKey)&steamid=\(steamId)&format=json&include_appinfo=1&include_played_free_games=1"
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(SteamGamesResponse.self, from: data) else {
            return []
        }
        
        return response.response.games.sorted { $0.playtimeForever > $1.playtimeForever }
    }
    
    func fetchUserProfile(steamId: String) async -> SteamUserProfile? {
        let urlString = "\(baseUrl)/ISteamUser/GetPlayerSummaries/v0002/?key=\(apiKey)&steamids=\(steamId)"
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(SteamUserProfileResponse.self, from: data),
              let profile = response.response.players.first else {
            return nil
        }
        
        return profile
    }
    
    func fetchUserAchievements(steamId: String, appId: Int) async -> [SteamAchievement] {
        let urlString = "\(baseUrl)/ISteamUserStats/GetPlayerAchievements/v0001/?appid=\(appId)&key=\(apiKey)&steamid=\(steamId)"
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(SteamAchievementsResponse.self, from: data) else {
            return []
        }
        
        return response.playerstats.achievements ?? []
    }
    
    func fetchAchievementSchema(appId: Int) async -> [AchievementSchema] {
        let urlString = "\(baseUrl)/ISteamUserStats/GetSchemaForGame/v2/?key=\(apiKey)&appid=\(appId)"
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(AchievementSchemaResponse.self, from: data) else {
            return []
        }
        
        return response.game?.availableGameStats?.achievements ?? []
    }
}
