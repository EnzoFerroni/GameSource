//
//  GameDetailView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import SwiftUI

struct GameDetailView: View {
    let game: Game
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Image
                        AsyncImage(url: URL(string: game.headerImage ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.secondaryBackground)
                                .overlay(
                                    Image(systemName: "gamecontroller.fill")
                                        .foregroundColor(.mediumGray)
                                        .font(.largeTitle)
                                )
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Game Title
                            Text(game.name ?? "Unknown Game")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Game Info Grid
                            VStack(alignment: .leading, spacing: 12) {
                                if let genre = game.shortDescription, !genre.isEmpty {
                                    InfoRow(label: "Gênero:", value: genre)
                                }
                                
                                if let price = game.price, !price.isEmpty {
                                    InfoRow(label: "Preço:", value: price)
                                }
                                
                                if let releaseDate = game.releaseDate, !releaseDate.isEmpty {
                                    InfoRow(label: "Lançamento:", value: releaseDate)
                                }
                                
                                if let developers = game.developers, !developers.isEmpty {
                                    InfoRow(label: "Desenvolvedores:", value: developers)
                                }
                                
                                if let publishers = game.publishers, !publishers.isEmpty {
                                    InfoRow(label: "Publicadores:", value: publishers)
                                }
                            }
                            
                            // Add to Library Button
                            Button(action: {
                                // Action to add to library
                            }) {
                                Text("Adicionar à lista")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Biblioteca") {
                        isPresented = false
                    }
                    .foregroundColor(.accentBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        game.isFavorite.toggle()
                        viewModel.saveContext()
                    }) {
                        Image(systemName: game.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(game.isFavorite ? .red : .white)
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.mediumGray)
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleGame = Game(context: context)
    sampleGame.appId = 1091500
    sampleGame.name = "Cyberpunk 2077"
    sampleGame.shortDescription = "RPG, Ação"
    sampleGame.headerImage = "https://cdn.akamai.steamstatic.com/steam/apps/1091500/header.jpg"
    sampleGame.price = "R$ 199,99"
    sampleGame.releaseDate = "10 de dezembro de 2020"
    sampleGame.developers = "CD PROJEKT RED"
    sampleGame.publishers = "CD PROJEKT RED"
    
    return GameDetailView(
        game: sampleGame,
        isPresented: .constant(true),
        viewModel: GamesViewModel()
    )
}