import Foundation

struct SteamUserProfileResponse: Codable {
    let response: SteamUserProfileData
}

struct SteamUserProfileData: Codable {
    let players: [SteamUserProfile]
}

struct SteamUserProfile: Codable {
    let steamid: String
    let personaname: String
    let avatar: String
}
