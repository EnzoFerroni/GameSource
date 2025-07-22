//
//  GameSourceApp.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import SwiftUI

@main
struct GameSourceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
