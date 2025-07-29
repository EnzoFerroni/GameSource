import SwiftUI

// MARK: - Enhanced AchievementRow with Images

struct AchievementRowWithImages: View {
    let achievement: SteamAchievement
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Achievement Icon
            AsyncImage(url: URL(string: achievement.displayIconUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: achievement.isUnlocked ? "trophy.fill" : "trophy")
                            .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                            .font(.caption)
                    )
            }
            .frame(width: 40, height: 40)
            .cornerRadius(6)
            
            // Achievement Details
            VStack(alignment: .leading, spacing: 4) {
                // Achievement Name
                Text(achievement.name?.isEmpty == false ? achievement.name! : achievement.apiname.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
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
                
                // Unlock Status and Date
                HStack(spacing: 4) {
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                        
                        if let unlockDate = achievement.unlockDate {
                            Text("Unlocked on \(formatAchievementDate(unlockDate))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Unlocked")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.caption2)
                        
                        Text("Not unlocked")
                            .font(.caption2)
                            .foregroundColor(.secondary)
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
    VStack {
        AchievementRowWithImages(
            achievement: SteamAchievement(
                apiname: "FIRST_KILL",
                achieved: 1,
                unlocktime: 1640995200,
                name: "First Blood",
                description: "Get your first kill in the game",
                iconUrl: "https://example.com/icon.jpg",
                iconGrayUrl: "https://example.com/icon_gray.jpg"
            )
        )
        
        AchievementRowWithImages(
            achievement: SteamAchievement(
                apiname: "MASTER_EXPLORER",
                achieved: 0,
                unlocktime: 0,
                name: "Master Explorer",
                description: "Explore all areas of the game world",
                iconUrl: "https://example.com/icon2.jpg",
                iconGrayUrl: "https://example.com/icon2_gray.jpg"
            )
        )
    }
    .padding()
}