//
//  GameSourceApp.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// App entry point. SwiftUI builds the whole scene from here,
// so there is no need for AppDelegate or storyboards.
@main
struct GameSourceApp: App {
    var body: some Scene {
        WindowGroup {
            GameLibraryView()
        }
    }
}
