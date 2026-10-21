//
//  HomeView.swift
//  Kinovechor
//
//  Created by Свят on 17.10.26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var roomManager: RoomManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Главный экран")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let email = authManager.user?.email {
                Text("Вы вошли как:\n\(email)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            if let roomId = roomManager.currentRoomId {
                VStack(spacing: 8) {
                    Text("Код вашей комнаты:")
                        .foregroundStyle(.secondary)
                    
                    Text(roomId)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            Button("Покинуть комнату") {
                roomManager.leaveRoom()
            }
            .foregroundStyle(.red)
            .padding(.top, 20)
            
            Button(action: {
                authManager.signOut()
            }) {
                Text("Выйти из аккаунта")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
        .environmentObject(RoomManager())
}
