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
    
    @State private var isEditingName = false
    @State private var newDisplayName = ""
    @State private var showSuccessAlert = false
    
    @State private var isChangingRoomPassword = false
    @State private var newRoomPassword = ""
    @State private var showRoomPasswordSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                profileSection
                roomSection
                accountSection
            }
            .alert("Сменить пароль комнаты", isPresented: $isChangingRoomPassword) {
                SecureField("Новый пароль", text: $newRoomPassword)
                Button("Отмена", role: .cancel) {}
                Button("Сохранить") {
                    roomManager.updateRoomPassword(newPassword: newRoomPassword) { success in
                        if success {
                            showRoomPasswordSuccessAlert = true
                        }
                    }
                }
            } message: {
                Text("Введите новый пароль комнаты. Участники смогут входить только по нему")
            }
            .alert("Пароль изменен", isPresented: $showRoomPasswordSuccessAlert) {
                Button("Ок", role: .cancel) {}
            } message: {
                Text("Новый пароль комнаты успешно сохранен.")
            }
            .alert("Изменить имя", isPresented: $isEditingName) {
                TextField("Введите имя", text: $newDisplayName)
                Button("Отмена", role: .cancel) {}
                Button("Сохранить") {
                    authManager.updateProfile(newName: newDisplayName) { success in
                        if success {
                            showSuccessAlert = true
                        }
                    }
                }
            } message: {
                Text("Введите новое отображаемое имя для вашего профиля")
            }
            .alert("Успешно!", isPresented: $showSuccessAlert) {
                Button("Ок", role: .cancel) {}
            } message: {
                Text("Имя профиля успешного обновлено.")
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
    
    // MARK: Profile section
    private var profileSection : some View {
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
            
            
            Button(action: {
                newDisplayName = authManager.user?.displayName ?? ""
                isEditingName = true
            }) {
                if authManager.isUpdatingName {
                    HStack(alignment: .center) {
                        Spacer()
                        ProgressView()
                            .tint(.blue)
                        Spacer()
                    }
                } else {
                    Label("Измененить имя профиля", systemImage: "pencil")
                }
            }
            .disabled(authManager.isUpdatingName)
            
        }
    }
    
    // MARK: Room section
    private var roomSection : some View {
        Section("Текущая комната") {
            if let roomId = roomManager.currentRoomId {
                // ID
                HStack {
                    Label("ID комнаты", systemImage: "number.square")
                    Spacer()
                    Text(roomId)
                        .bold()
                        .foregroundStyle(.blue)
                }
                
                // Members
                if roomManager.roomMembers.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(roomManager.roomMembers, id: \.self) { memberUidString in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                let isMe = memberUidString == authManager.user?.uid
                                
                                Text(isMe ? "Вы" : "Участник")
                                    .font(.headline)
                                
                                Text(memberUidString.prefix(8) + "...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if memberUidString == roomManager.currentCreatorId {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                    .font(.subheadline)
                            }
                            
                            let isHost = roomManager.currentCreatorId == authManager.user?.uid
                            let isMe = memberUidString == authManager.user?.uid
                            
                            if isHost, !isMe {
                                Button(role: .destructive) {
                                    roomManager.kickMember(targetUid: memberUidString) { success in
                                        if success { }
                                    }
                                } label: {
                                    Image(systemName: "person.badge.minus")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
                
                // Change password
                let isCretor = roomManager.currentCreatorId == authManager.user?.uid
                
                if isCretor {
                    Button(action: {
                        newRoomPassword = ""
                        isChangingRoomPassword = true
                    }) {
                        if roomManager.isChangingRoomPassword {
                            HStack(alignment: .center) {
                                Spacer()
                                ProgressView()
                                    .tint(.blue)
                                Spacer()
                            }
                        } else {
                            Label("Изменить пароль комнаты", systemImage: "lock.rotation")
                        }
                    }
                    .disabled(roomManager.isChangingRoomPassword)
                }
                
                // Leaeve form room button
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
        .onAppear {
            roomManager.fetchRoomMembers()
        }
    }
    
    // MARK: Account section
    private var accountSection : some View {
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
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
        .environmentObject(RoomManager())
}
