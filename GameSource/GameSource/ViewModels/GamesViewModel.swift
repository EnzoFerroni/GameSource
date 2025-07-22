//
//  GamesViewModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import Foundation
import CoreData
import Combine

@MainActor
class GamesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var games: [Game] = []
    @Published var favoriteGames: [Game] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let steamAPIService = SteamAPIService()
    private var viewContext: NSManagedObjectContext?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Empty initializer for @StateObject compatibility
    }
    
    // MARK: - Public Methods
    func setContext(_ context: NSManagedObjectContext) {
        viewContext = context
        loadGamesFromCoreData()
        loadFavoriteGames()
    }
    
    func loadGames() async {
        await fetchGamesFromAPI()
    }
    
    func toggleFavorite(game: Game) {
        guard let viewContext = viewContext else { 
            errorMessage = "Core Data context not available"
            return 
        }
        
        game.isFavorite.toggle()
        saveContext()
        loadFavoriteGames()
    }
    
    func deleteGame(_ game: Game) {
        guard let viewContext = viewContext else { 
            errorMessage = "Core Data context not available"
            return 
        }
        
        viewContext.delete(game)
        saveContext()
        loadGamesFromCoreData()
        loadFavoriteGames()
    }
    
    func clearAllGames() {
        guard let viewContext = viewContext else { 
            errorMessage = "Core Data context not available"
            return 
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Game.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            saveContext()
            games.removeAll()
            favoriteGames.removeAll()
        } catch {
            errorMessage = "Failed to clear games: \(error.localizedDescription)"
        }
    }
    
    func saveContext() {
        guard let viewContext = viewContext else { return }
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                errorMessage = "Failed to save context: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadGamesFromCoreData() {
        guard let viewContext = viewContext else { return }
        
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Game.name, ascending: true)]
        
        do {
            games = try viewContext.fetch(request)
        } catch {
            errorMessage = "Failed to load games: \(error.localizedDescription)"
        }
    }
    
    private func loadFavoriteGames() {
        guard let viewContext = viewContext else { return }
        
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Game.name, ascending: true)]
        
        do {
            favoriteGames = try viewContext.fetch(request)
        } catch {
            errorMessage = "Failed to load favorite games: \(error.localizedDescription)"
        }
    }
    
    private func fetchGamesFromAPI() async {
        guard let viewContext = viewContext else {
            errorMessage = "Core Data context not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let steamApps = try await steamAPIService.fetchFeaturedGames()
            
            for steamApp in steamApps {
                await saveGameToCoreData(steamApp: steamApp, context: viewContext)
            }
            
            loadGamesFromCoreData()
            loadFavoriteGames()
        } catch {
            errorMessage = "Failed to fetch games: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func saveGameToCoreData(steamApp: SteamApp, context: NSManagedObjectContext) async {
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSPredicate(format: "appId == %d", steamApp.appid)
        
        do {
            let existingGames = try context.fetch(request)
            
            guard existingGames.isEmpty else { return }
            
            let game = Game(context: context)
            game.appId = steamApp.appid
            game.name = steamApp.name
            game.isFavorite = false
            game.createdAt = Date()
            
            // Try to get detailed information
            if let gameDetails = try? await steamAPIService.fetchGameDetails(appId: steamApp.appid) {
                game.shortDescription = gameDetails.shortDescription
                game.headerImage = gameDetails.headerImage
                game.price = gameDetails.priceOverview?.finalFormatted
                game.releaseDate = gameDetails.releaseDate?.date
                game.developers = gameDetails.developers?.joined(separator: ", ")
                game.publishers = gameDetails.publishers?.joined(separator: ", ")
            }
            
            try context.save()
        } catch {
            print("Failed to save game: \(error.localizedDescription)")
        }
    }
}
