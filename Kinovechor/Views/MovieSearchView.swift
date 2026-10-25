//
//  MovieSearchView.swift
//  Kinovechor
//
//  Created by Свят on 23.10.26.
//

import SwiftUI

struct MovieSearchView: View {
    @StateObject private var tmdbManager = TMDBManager()
    @State private var searchQuery : String = ""
    @State private var selectedMovie : Movie? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                if tmdbManager.isLoading, (searchQuery.isEmpty ? tmdbManager.popularMovies.isEmpty : tmdbManager.movies.isEmpty) {
                    ProgressView("Ищем фильмы...")
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if searchQuery.isEmpty {
                                Text("🔥 Сегодня в тренде")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
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
                                    }
                                    .padding(.horizontal)
                                }
                            } else {
                                if let error = tmdbManager.errorMessage, tmdbManager.movies.isEmpty {
                                    Text(error)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, minHeight: 300)
                                }
                                else {
                                    ForEach(tmdbManager.movies) { movie in
                                        MovieRow(movie: movie) {
                                            selectedMovie = movie
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
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
        }
    }
}

#Preview {
    MovieSearchView()
}
