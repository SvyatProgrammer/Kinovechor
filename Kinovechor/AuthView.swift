//
//  AuthView.swift
//  Kinovechor
//
//  Created by Свят on 17.10.26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    Image(systemName: "film.stack.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    VStack(spacing: 8) {
                        Text(isRegistering ? "Создать аккаунт" : "C возвращением")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isRegistering ? "Зарегистрируйтесь, чтобы продолжить" : "Войдите в свой аккаунт")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(.secondary)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundStyle(.secondary)
                            SecureField("Пароль", text: $password)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                    }
                    .disabled(isLoading
                    )
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        isLoading = true
                        authManager.errorMessage = nil
                        
                        if isRegistering {
                            authManager.signUp(email: email, password: password) { _ in
                                // Automatic redirect
                                isLoading = false
                            }
                        } else {
                            authManager.signIn(email: email, password: password) { _ in
                                // Automatic redirect
                                isLoading = false
                            }
                        }
                    }) {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isRegistering ? "Зарегистрироваться" : "Войти")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    .padding(.top, 10)
                    
                    Button(action: {
                        withAnimation {
                            isRegistering.toggle()
                            authManager.errorMessage = nil
                        }
                    }) {
                        Text(isRegistering ? "Уже есть аккаунт? **Войти**" : "Нет аккаунта? **Зарегистрироваться**")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .disabled(isLoading)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
