//
//  GameSourceApp.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// App entry point. SwiftUI builds the whole scene from here.
@main
struct GameSourceApp: App {

    // SteamID saved on the device. Empty means nobody is logged in.
    // Changing it makes SwiftUI swap the root view automatically.
    @AppStorage(StorageKey.steamID) private var steamID = ""

    var body: some Scene {
        WindowGroup {
            if steamID.isEmpty {
                LoginView()
            }
            else {
                GameLibraryView()
            }
        }
    }
}
