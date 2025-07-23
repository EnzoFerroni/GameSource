import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Steam Test")
                .font(.title)
            
            if authViewModel.isAuthenticated {
                Text("Login OK!")
                    .foregroundColor(.green)
                
                if let steamID = authViewModel.steamID {
                    Text("ID: \(steamID)")
                }
                
                Button("Logout") {
                    authViewModel.signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Button("Login Steam") {
                    authViewModel.signInWithSteam()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
