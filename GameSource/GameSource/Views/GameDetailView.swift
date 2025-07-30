import SwiftUI

struct GameDetailView: View {
    let game: SteamGame
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var achievements: [SteamAchievement] = []
    @State private var achievementSchemas: [AchievementSchema] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    AsyncImage(url: URL(string: headerImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(
                                VStack {
                                    Image(systemName: "gamecontroller")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                    Text("Loading...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text(game.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        VStack(spacing: 16) {
                            StatRow(
                                icon: "clock",
                                title: "Total Playtime",
                                value: formatPlaytime(minutes: game.playtimeForever)
                            )
                            
                            StatRow(
                                icon: "gamecontroller",
                                title: "App ID",
                                value: "\(game.appid)"
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        achievementsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadAchievements()
        }
    }
        
    private var headerImageURL: String {
        return "https://shared.steamstatic.com/store_item_assets/steam/apps/\(game.appid)/header.jpg"
    }
        
    private func formatPlaytime(minutes: Int) -> String {
        let hours = minutes / 60
        return hours > 0 ? "\(hours) hours" : "Not played"
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.headline)
            
            if achievements.isEmpty {
                Text("No achievements available")
                    .foregroundColor(.secondary)
            } else {
                LazyVStack {
                    ForEach(achievements) { achievement in
                        let schema = achievementSchemas.first { $0.name == achievement.apiname }
                        AchievementRowView(achievement: achievement, schema: schema)
                    }
                }
            }
        }
    }
    
    private func loadAchievements() async {
        guard let steamId = authViewModel.steamID else { return }
        let steamService = SteamService()
        
        async let userAchievements = steamService.fetchUserAchievements(steamId: steamId, appId: game.appid)
        async let gameSchema = steamService.fetchAchievementSchema(appId: game.appid)
        
        achievements = await userAchievements
        achievementSchemas = await gameSchema
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    GameDetailView(game: SteamGame(
        appid: 440,
        name: "Team Fortress 2",
        playtimeForever: 2400,
        imgIconUrl: ""
    ))
}
