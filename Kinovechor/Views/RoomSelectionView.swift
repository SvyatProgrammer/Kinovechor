//
//  RoomSelectionView.swift
//  Kinovechor
//
//  Created by Свят on 20.10.26.
//

import SwiftUI

struct RoomSelectionView: View {
    
    @EnvironmentObject var authManager : AuthManager
    @EnvironmentObject var roomManager : RoomManager
    
    @State private var isCreating = true
    
    @State private var roomId = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Title
                    VStack(spacing: 8) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                            .padding(.bottom, 10)
                        
                        Text(isCreating ? "Создать комнату" : "Войти в комнату")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isCreating ? "Задайте пароль, чтобы создать комнату" : "Введите ID и пароль комнаты, чтобы присоедениться")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Inputs
                    VStack(spacing: 16) {
                        if !isCreating {
                            HStack {
                                Image(systemName: "number")
                                    .foregroundStyle(.secondary)
                                TextField("ID комнаты (например: 201026)", text: $roomId)
                                    .keyboardType(.numberPad)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundStyle(.secondary)
                            SecureField("Пароль комнаты", text: $password)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    
                    // Error
                    if let errorMessage = roomManager.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Success button
                    Button(action: {
                        isLoading = true
                        roomManager.errorMessage = nil
                        
                        if isCreating {
                            roomManager.createRoom(password: password) { _ in
                                isLoading = false
                            }
                        } else {
                            roomManager.joinRoom(roomId: roomId, password: password) { _ in
                                isLoading = false
                            }
                        }
                    }) {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isCreating ? "Создать" : "Войти")
                                    .font(.headline)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || password.isEmpty || (!isCreating && roomId.isEmpty))
                    
                    // Switch button
                    Button(action: {
                        withAnimation {
                            isCreating.toggle()
                            roomManager.errorMessage = nil
                        }
                    }) {
                        Text(isCreating ? "Уже есть ID комнаты? **Войти**" : "Хотите создать свою? **Создать**")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    .disabled(isLoading)
                    
                    Spacer()
                    
                    // Leave from account button
                    Button(role: .destructive, action: {
                        authManager.signOut()
                    }) {
                        Text("Выйти из аккаунта")
                            .font(.subheadline)
                    }
                    .padding(.bottom, 20)
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    RoomSelectionView()
        .environmentObject(AuthManager())
        .environmentObject(RoomManager())
}
