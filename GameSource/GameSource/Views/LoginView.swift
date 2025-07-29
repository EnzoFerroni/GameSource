import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            AppHeaderView(
                iconName: "gamecontroller.fill",
                title: "GameSource",
                subtitle: "Connect with Steam to get started"
            )
            
            
            VStack(spacing: 20) {
                SteamLoginButton(isLoading: authViewModel.isLoading) {
                    authViewModel.signInWithSteam()
                }
            }
                        
            Text("By signing in, you agree to our terms of service")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
