import Foundation

struct SteamGamesResponse: Codable {
    let response: GamesList
}

struct GamesList: Codable {
    let gameCount: Int
    let games: [SteamGame]
    
    enum CodingKeys: String, CodingKey {
        case gameCount = "game_count"
        case games
    }
}

struct SteamGame: Codable, Identifiable {
    let appid: Int
    let name: String
    let playtimeForever: Int
    let imgIconUrl: String
    
    enum CodingKeys: String, CodingKey {
        case appid
        case name
        case playtimeForever = "playtime_forever"
        case imgIconUrl = "img_icon_url"
    }
    
    var id: Int {
        appid
    }
    
    var imageUrl: String {
        "https://shared.steamstatic.com/store_item_assets/steam/apps/\(appid)/library_600x900.jpg"
    }
}
