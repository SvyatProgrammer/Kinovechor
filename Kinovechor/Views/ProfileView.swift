//
//  ProfileView.swift
//  Kinovechor
//
//  Created by Свят on 21.10.26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var authManager : AuthManager
    @EnvironmentObject var roomManager : RoomManager
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "person.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.user?.displayName ?? "Пользователь")
                                .font(.headline)
                            
                            Text(authManager.user?.email ?? "Email не указан")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Текущая комната") {
                    if let roomId = roomManager.currentRoomId {
                        HStack {
                            Label("ID комнаты", systemImage: "number.square")
                            Spacer()
                            Text(roomId)
                                .bold()
                                .foregroundStyle(.blue)
                        }
                        
                        Button(role: .destructive, action: {
                            roomManager.leaveRoom()
                            dismiss()
                        }) {
                            Label("Покинуть комнату", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        Text("Вы не состоите в комнате")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Аккаунт") {
                    HStack {
                        Label("UID", systemImage: "key.fill")
                        Spacer()
                        Text(authManager.user?.uid.prefix(8) ?? "-")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(role: .destructive, action: {
                        authManager.signOut()
                        roomManager.resetLocalState()
                        dismiss()
                    }) {
                        Label("Выйти из аккаунта", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
        .environmentObject(RoomManager())
}
