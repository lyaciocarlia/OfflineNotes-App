import SwiftUI

struct ConnectionBanner: View {
    var isConnected: Bool

    var body: some View {
        HStack {
            Image(systemName: isConnected ? "wifi" : "wifi.slash")
            Text(isConnected ? "Online" : "Offline")
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isConnected ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
        .foregroundStyle(isConnected ? .green : .red)
        .clipShape(Capsule())
    }
}
