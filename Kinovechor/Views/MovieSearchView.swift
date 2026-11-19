//
//  MovieSearchView.swift
//  Kinovechor
//
//  Created by Свят on 23.10.26.
//

import SwiftUI

struct MovieSearchView: View {
    @EnvironmentObject var roomManager: RoomManager
    @StateObject private var tmdbManager = TMDBManager()
    @State private var searchQuery : String = ""
    @State private var selectedMovie : Movie? = nil
    @State private var movieToAddToLibrary : Movie? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                if tmdbManager.isLoading, (searchQuery.isEmpty ? tmdbManager.isLoadingPopularMovies : tmdbManager.movies.isEmpty) {
                    ProgressView("Ищем фильмы...")
                } else {
                    List {
                        if searchQuery.isEmpty {
                            if let error = tmdbManager.errorMessage, tmdbManager.popularMovies.isEmpty {
                                Text(error)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, minHeight: 300)
                            } else {
                                ForEach(tmdbManager.popularMovies) { movie in
                                    MovieRow(movie: movie) {
                                        selectedMovie = movie
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        if roomManager.currentRoomId != nil {
                                            Button {
                                                movieToAddToLibrary = movie
                                            } label: {
                                                Label("В комнату", systemImage: "plus.circle.fill")
                                            }
                                            .tint(.green)
                                        }
                                    }
                                }
                            }
                        } else {
                            if let error = tmdbManager.errorMessage, tmdbManager.movies.isEmpty {
                                Text(error)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, minHeight: 300)
                            } else {
                                ForEach(tmdbManager.movies) { movie in
                                    MovieRow(movie: movie) {
                                        selectedMovie = movie
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        if roomManager.currentRoomId != nil {
                                            Button {
                                                movieToAddToLibrary = movie
                                            } label: {
                                                Label("В комнату", systemImage: "plus.circle.fill")
                                            }
                                            .tint(.green)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Поиск фильма")
            .searchable(text: $searchQuery, prompt: "Название фильма...")
            .onChange(of: searchQuery) { newValue in
                tmdbManager.searchMovies(query: newValue)
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
            .sheet(item: $movieToAddToLibrary) { movie in
                AddLibraryItemView(movie: movie)
            }
        }
    }
}

#Preview {
    MovieSearchView()
        .environmentObject(RoomManager())
}
