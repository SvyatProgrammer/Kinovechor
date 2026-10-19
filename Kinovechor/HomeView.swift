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

    var body: some View {
        VStack(spacing: 20) {
            Text("Добро пожаловать!")
                .font(.largeTitle)
            
            if let email = authManager.user?.email {
                Text("Вы вошли как:\n\(email)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
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
}
