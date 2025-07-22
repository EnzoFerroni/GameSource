//
//  Persistence.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample games for preview
        let sampleGame1 = Game(context: viewContext)
        sampleGame1.appId = 730
        sampleGame1.name = "Counter-Strike: Global Offensive"
        sampleGame1.shortDescription = "Counter-Strike: Global Offensive (CS: GO) expands upon the team-based action gameplay that it pioneered when it was launched 19 years ago."
        sampleGame1.headerImage = "https://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg"
        sampleGame1.price = "Free To Play"
        sampleGame1.releaseDate = "Aug 21, 2012"
        sampleGame1.developers = "Valve, Hidden Path Entertainment"
        sampleGame1.publishers = "Valve"
        sampleGame1.isFavorite = false
        sampleGame1.createdAt = Date()
        
        let sampleGame2 = Game(context: viewContext)
        sampleGame2.appId = 570
        sampleGame2.name = "Dota 2"
        sampleGame2.shortDescription = "Every day, millions of players worldwide enter battle as one of over a hundred Dota heroes."
        sampleGame2.headerImage = "https://cdn.akamai.steamstatic.com/steam/apps/570/header.jpg"
        sampleGame2.price = "Free To Play"
        sampleGame2.releaseDate = "Jul 9, 2013"
        sampleGame2.developers = "Valve"
        sampleGame2.publishers = "Valve"
        sampleGame2.isFavorite = true
        sampleGame2.createdAt = Date()
        
        // Keep the original Item for backward compatibility
        for _ in 0..<3 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "GameSource")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure for CloudKit
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
