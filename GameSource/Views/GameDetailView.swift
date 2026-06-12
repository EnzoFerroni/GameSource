//
//  GameDetailView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// Detail sheet for a game: banner, stats, achievements and a store link.
struct GameDetailView: View {

    let game: SteamGame

    @StateObject private var viewModel = GameDetailViewModel()

    // Needed for the achievements request, since they are per user.
    @AppStorage("steamID") private var steamID = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    banner

                    Text(game.name)
                        .font(.title2.bold())

                    stats

                    achievementsSection

                    if let storeURL {
                        Link(destination: storeURL) {
                            Label("View on Steam Store", systemImage: "cart")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadAchievements(steamID: steamID, appId: game.appid)
        }
    }

    // Steam's wide banner keeps a 460x215 ratio.
    private var banner: some View {
        AsyncImage(url: game.headerURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(.quaternary)

                Image(systemName: "gamecontroller")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .aspectRatio(460 / 215, contentMode: .fit)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var stats: some View {
        VStack(spacing: 16) {
            statRow(
                icon: "clock",
                title: "Total Playtime",
                value: game.formattedPlaytime
            )

            statRow(
                icon: "gamecontroller",
                title: "App ID",
                value: "\(game.appid)"
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.orange)

                Text("Achievements")
                    .font(.headline)

                if !viewModel.achievements.isEmpty {
                    Text("(\(viewModel.unlockedCount)/\(viewModel.achievements.count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            else if viewModel.achievements.isEmpty {
                Text("No achievements available for this game.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            else {
                // Lazy because some games have hundreds of achievements.
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.achievements) { achievement in
                        achievementRow(achievement)
                    }
                }
            }
        }
    }

    private func achievementRow(_ achievement: SteamAchievement) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: achievement.isUnlocked
                ? "checkmark.circle.fill"
                : "circle")
                .foregroundStyle(achievement.isUnlocked ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .font(.subheadline.weight(.medium))

                if let description = achievement.description,
                   !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }

    private var storeURL: URL? {
        URL(string: "https://store.steampowered.com/app/\(game.appid)")
    }
}

#Preview {
    GameDetailView(
        game: SteamGame(appid: 440, name: "Team Fortress 2", playtimeForever: 7500)
    )
}
