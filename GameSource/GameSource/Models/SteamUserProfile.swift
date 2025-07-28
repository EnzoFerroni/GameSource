//
//  SteamUserProfile.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

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
    let profileurl: String
    let avatar: String
    let avatarmedium: String
    let avatarfull: String
}