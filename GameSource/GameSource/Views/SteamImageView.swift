import SwiftUI

struct SteamImageView: View {
    let appid: Int
    
    private var imageUrl: String {
        "https://shared.steamstatic.com/store_item_assets/steam/apps/\(appid)/library_600x900.jpg"
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(contentMode: .fill)
            default:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.gray)
                    }
            }
        }
    }
}

#Preview {
    SteamImageView(appid: 440)
        .aspectRatio(2/3, contentMode: .fill)
        .frame(width: 160, height: 240)
        .clipped()
        .cornerRadius(8)
}
