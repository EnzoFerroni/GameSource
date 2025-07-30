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
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.8)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(8)
            
            VStack {
                Spacer()
                
                Text(game.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
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
    GameCardView(game: SteamGame(
        appid: 440,
        name: "Sample Game",
        playtimeForever: 60,
        imgIconUrl: ""
    ))
}
