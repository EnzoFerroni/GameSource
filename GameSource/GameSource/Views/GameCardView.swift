import SwiftUI

struct GameCardView: View {
    let game: SteamGame
    @State private var showingDetail = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            SteamImageView(appid: game.appid)
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: 160, height: 240)
                .clipped()
                .cornerRadius(8)
            
            // Gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.8)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(8)
            
            // Game name overlay
            VStack {
                Spacer()
                
                Text(game.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: 160, height: 240)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            GameDetailView(game: game)
        }
    }
}

#Preview {
    GameCardView(
        game: SteamGame(
            appid: 440,
            name: "Sample Game",
            playtimeForever: 60,
            playtime2Weeks: nil,
            imgIconUrl: "",
            imgLogoUrl: nil,
            hasCommunityVisibleStats: nil,
            rtimeLastPlayed: nil
        )
    )
}
