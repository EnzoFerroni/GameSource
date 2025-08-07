import SwiftUI

struct EmptyStateView: View {
    let onRefresh: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "gamecontroller")
                    .font(.system(size: 64))
                    .foregroundColor(.gray)
                
                VStack(spacing: 16) {
                    Text("No Games Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("This might happen for a few reasons:")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Privacy Settings Instructions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.blue)
                        Text("Privacy Settings")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("Games are hidden by default on Steam. You can change your Steam profile privacy settings:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        instructionStep(number: "1", text: "From your Steam Profile, click the Edit Profile link under your displayed badge")
                        instructionStep(number: "2", text: "Click the My Privacy Settings tab")
                        instructionStep(number: "3", text: "Set Game details to Public")
                        instructionStep(number: "4", text: "Uncheck Always keep my total playtime private option")
                    }
                    .padding(.leading, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Network Issues
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "wifi.exclamationmark")
                            .foregroundColor(.orange)
                        Text("Network Issues")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("Some networks (like school or work WiFi) might block gaming-related websites. Try using a different network or mobile data.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Refresh Button
                Button(action: onRefresh) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func instructionStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    EmptyStateView(onRefresh: {})
}
