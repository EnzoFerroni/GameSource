import SwiftUI

struct LibraryHeaderView: View {
    let userProfile: SteamUserProfile?
    let onProfileTap: () -> Void
    let onRandomGame: () -> Void
    let onNotifications: () -> Void
    
    var body: some View {
        HStack {
            Text("Library")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onRandomGame) {
                    Image(systemName: "dice")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Button(action: onNotifications) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                if let userProfile = userProfile {
                    Button(action: onProfileTap) {
                        AsyncImage(url: URL(string: userProfile.avatar)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
    }
}
