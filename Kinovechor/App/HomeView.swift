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

    @State private var showProfile = false
    @State private var selectedtab = 0
    
    var body: some View {
        TabView(selection: $selectedtab) {
            // MARK: Movies search
            NavigationStack {
                MovieSearchView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                showProfile = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    .environmentObject(roomManager)
            }
            .tabItem {
                Label("Фильмы", systemImage: "film")
            }
            .tag(0)
            
            // MARK: Main
            NavigationStack {
                MainView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                showProfile = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            .tag(1)
            
            // MARK: Library
            NavigationStack {
                LibraryView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                showProfile = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    .environmentObject(roomManager)
            }
            .tabItem {
                Label("Фильмотека", systemImage: "book")
            }
            .tag(2)
        }
        .tint(.blue)
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authManager)
                .environmentObject(roomManager)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
        .environmentObject(RoomManager())
}
