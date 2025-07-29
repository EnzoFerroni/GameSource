import SwiftUI

struct GameDetailView: View {
    let game: SteamGame
    @Environment(\.dismiss) private var dismiss
    
    @State private var achievements: [SteamAchievement] = []
    @State private var achievementStats: AchievementStats?
    @State private var isLoadingAchievements = false
    @State private var showAchievements = false
    
    private let steamService = SteamService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Game Header Image
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
                    
                    // MARK: - Game Info
                    VStack(alignment: .leading, spacing: 20) {
                        Text(game.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        // MARK: - Basic Stats
                        VStack(spacing: 16) {
                            StatRow(
                                icon: "clock",
                                title: "Total Playtime",
                                value: formatPlaytime(minutes: game.playtimeForever)
                            )
                            
                            if let recentPlaytime = game.playtime2Weeks {
                                StatRow(
                                    icon: "calendar",
                                    title: "Recent Playtime",
                                    value: formatPlaytime(minutes: recentPlaytime)
                                )
                            }
                            
                            if let lastPlayed = game.rtimeLastPlayed {
                                StatRow(
                                    icon: "clock.arrow.circlepath",
                                    title: "Last Played",
                                    value: formatLastPlayed(timestamp: lastPlayed)
                                )
                            }
                            
                            StatRow(
                                icon: "gamecontroller",
                                title: "App ID",
                                value: "\(game.appid)"
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // MARK: - Achievements Section
                        if game.hasCommunityVisibleStats == true {
                            VStack(alignment: .leading, spacing: 16) {
                                // Achievement Header with Expand/Collapse
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showAchievements.toggle()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "trophy")
                                            .foregroundColor(.yellow)
                                        
                                        Text("Achievements")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if isLoadingAchievements {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: showAchievements ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.blue)
                                                .rotationEffect(.degrees(showAchievements ? 0 : 0))
                                                .animation(.easeInOut(duration: 0.3), value: showAchievements)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Achievement Content (Expandable)
                                if showAchievements {
                                    VStack(spacing: 12) {
                                        if let stats = achievementStats {
                                            VStack(spacing: 12) {
                                                AchievementStatRow(
                                                    icon: "trophy.fill",
                                                    title: "Unlocked",
                                                    value: "\(stats.unlockedAchievements)/\(stats.totalAchievements)"
                                                )
                                                
                                                AchievementStatRow(
                                                    icon: "percent",
                                                    title: "Completion",
                                                    value: stats.formattedCompletion
                                                )
                                                
                                                // Progress Bar
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Progress")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    ProgressView(value: stats.completionPercentage / 100.0)
                                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                                }
                                            }
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                            
                                            Divider()
                                                .padding(.vertical, 8)
                                        }
                                        
                                        // Achievement List
                                        if !achievements.isEmpty {
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Text("All Achievements")
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                    
                                                    Spacer()
                                                    
                                                    Text("Tap to see details")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                LazyVStack(spacing: 8) {
                                                    ForEach(achievements, id: \.id) { achievement in
                                                        AchievementRow(achievement: achievement)
                                                    }
                                                }
                                            }
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        } else if !isLoadingAchievements {
                                            Text("No achievement data available")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .italic()
                                                .padding()
                                                .transition(.opacity)
                                        }
                                    }
                                    .animation(.easeInOut(duration: 0.3), value: achievements.count)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
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
            .task {
                await loadAchievements()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var headerImageURL: String {
        return "https://shared.steamstatic.com/store_item_assets/steam/apps/\(game.appid)/header.jpg"
    }
    
    // MARK: - Private Methods
    
    private func loadAchievements() async {
        guard game.hasCommunityVisibleStats == true else { return }
        
        isLoadingAchievements = true
        
        guard let steamId = UserDefaults.standard.string(forKey: "steamId") else {
            print("No Steam ID found in UserDefaults")
            isLoadingAchievements = false
            return
        }
        
        print("Loading achievements for game \(game.appid) and Steam ID \(steamId)")
        
        achievements = await steamService.fetchGameAchievements(steamId: steamId, appId: game.appid)
        
        print("Loaded \(achievements.count) achievements")
        for achievement in achievements.prefix(3) {
            print("Achievement: \(achievement.name ?? "No name") - \(achievement.apiname)")
        }
        
        if !achievements.isEmpty {
            achievementStats = steamService.calculateAchievementStats(achievements: achievements)
        }
        
        isLoadingAchievements = false
    }
    
    // MARK: - Private Methods
    
    private func formatPlaytime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours == 0 {
            return "\(minutes) min"
        } else if remainingMinutes == 0 {
            return "\(hours) hrs"
        } else {
            return "\(hours)h \(remainingMinutes)m"
        }
    }
    
    private func formatLastPlayed(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

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

struct AchievementStatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 20)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
        }
    }
}

struct AchievementRow: View {
    let achievement: SteamAchievement
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Achievement Status Icon
            Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(achievement.isUnlocked ? .green : .gray)
                .frame(width: 20)
                .padding(.top, 2)
            
            // Achievement Details
            VStack(alignment: .leading, spacing: 4) {
                // Achievement Name - with fallback to API name
                Text(achievement.name?.isEmpty == false ? achievement.name! : achievement.apiname)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Achievement Description
                if let description = achievement.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Hidden Achievement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                // Unlock Date
                if achievement.isUnlocked {
                    if let unlockDate = achievement.unlockDate {
                        Text("Unlocked on \(formatAchievementDate(unlockDate))")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    } else {
                        Text("Unlocked")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatAchievementDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    GameDetailView(
        game: SteamGame(
            appid: 440,
            name: "Team Fortress 2",
            playtimeForever: 2400,
            playtime2Weeks: 120,
            imgIconUrl: "",
            imgLogoUrl: nil,
            hasCommunityVisibleStats: true,
            rtimeLastPlayed: 1640995200
        )
    )
}
