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

    // Achievements start collapsed; the header summary is always visible.
    @State private var showingAchievements = false

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
            if viewModel.isLoading {
                achievementsTitle

                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            else if viewModel.achievements.isEmpty {
                achievementsTitle

                Text("No achievements available for this game.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            else {
                // The header with the progress summary stays visible;
                // expanding reveals the full list.
                DisclosureGroup(isExpanded: $showingAchievements) {
                    // Lazy because some games have hundreds of them.
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.achievements) { achievement in
                            achievementRow(achievement)
                        }
                    }
                    .padding(.top, 12)
                } label: {
                    achievementsHeader
                }
                .tint(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var achievementsTitle: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .foregroundStyle(.orange)

            Text("Achievements")
                .font(.headline)
        }
    }

    // Unlocked count, percentage and progress bar in one glance.
    private var achievementsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                achievementsTitle

                Spacer()

                Text("\(viewModel.unlockedCount)/\(viewModel.achievements.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.completion)

            Text("\(Int(viewModel.completion * 100))% complete")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.trailing, 8)
    }

    private func achievementRow(_ achievement: GameAchievement) -> some View {
        HStack(alignment: .top, spacing: 12) {
            achievementIcon(achievement)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(
                        achievement.isUnlocked ? Color.primary : Color.secondary
                    )

                if let description = achievement.description,
                   !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let date = achievement.unlockDate {
                    Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            Image(systemName: achievement.isUnlocked
                ? "checkmark.circle.fill"
                : "lock.circle.fill")
                .foregroundStyle(
                    achievement.isUnlocked ? Color.green : Color.secondary
                )
        }
    }

    // The icon Steam provides: colored when unlocked, gray otherwise.
    private func achievementIcon(_ achievement: GameAchievement) -> some View {
        AsyncImage(url: achievement.iconURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(.quaternary)

                Image(systemName: "trophy")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
