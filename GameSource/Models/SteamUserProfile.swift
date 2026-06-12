//
//  SteamUserProfile.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation

// Mirrors the JSON returned by Steam's GetPlayerSummaries endpoint:
// { "response": { "players": [...] } }
struct SteamUserProfileResponse: Decodable {
    let response: PlayerList
}

struct PlayerList: Decodable {
    let players: [SteamUserProfile]
}

// The public profile of the logged user: name and avatar.
struct SteamUserProfile: Decodable {
    let personaname: String
    let avatar: String

    var avatarURL: URL? {
        URL(string: avatar)
    }
}
