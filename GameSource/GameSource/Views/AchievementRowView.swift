import SwiftUI

struct AchievementRowView: View {
    let achievement: SteamAchievement
    let schema: AchievementSchema?
    
    init(achievement: SteamAchievement, schema: AchievementSchema? = nil) {
        self.achievement = achievement
        self.schema = schema
    }
    
    var body: some View {
        HStack {
            achievementImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(displayDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                statusText
            }
            
            Spacer()
            
            statusIcon
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    private var achievementImage: some View {
        AsyncImage(url: URL(string: imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .saturation(achievement.isUnlocked ? 1.0 : 0.0)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.gray)
                }
        }
        .frame(width: 64, height: 64)
        .cornerRadius(8)
    }
    
    private var statusIcon: some View {
        Group {
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
    }
    
    private var statusText: some View {
        Group {
            if achievement.isUnlocked, let unlockDate = achievement.formattedUnlockDate {
                Text("Unlocked: \(unlockDate)")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            } else if !achievement.isUnlocked {
                Text("Not unlocked")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
        }
    }
    
    private var displayName: String {
        if let schemaName = schema?.displayName {
            return schemaName
        }
        return achievement.displayName
    }
    
    private var displayDescription: String {
        if let schemaDescription = schema?.description {
            return schemaDescription
        }
        return achievement.displayDescription
    }
    
    private var imageUrl: String {
        if achievement.isUnlocked {
            return schema?.icon ?? ""
        } else {
            return schema?.icongray ?? schema?.icon ?? ""
        }
    }
}
