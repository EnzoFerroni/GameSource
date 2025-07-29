import SwiftUI

struct LibraryHeaderView: View {
    let userProfile: SteamUserProfile?
    let onLogout: () -> Void
    
    var body: some View {
        HStack {
            Text("Library")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(spacing: 12) {
                if let userProfile = userProfile {
                    AsyncImage(url: URL(string: userProfile.avatarmedium)) { image in
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
                
                Button("Logout") {
                    onLogout()
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

#Preview {
    LibraryHeaderView(userProfile: nil) {
        print("Logout tapped")
    }
}
