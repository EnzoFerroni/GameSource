import SwiftUI

struct GameGridView: View {
    let games: [SteamGame]
    let onRefresh: () -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(games) { game in
                    GameCardView(game: game)
                }
            }
            .padding()
        }
        .refreshable {
            onRefresh()
        }
    }
}
