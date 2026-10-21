import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var roomManager = RoomManager()

    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                AuthView()
                    .environmentObject(authManager)
            } else if !roomManager.isInRoom {
                RoomSelectionView()
                    .environmentObject(authManager)
                    .environmentObject(roomManager)
            } else {
                HomeView()
                    .environmentObject(authManager)
                    .environmentObject(roomManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
