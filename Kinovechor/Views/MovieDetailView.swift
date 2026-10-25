//
//  MovieDetailView.swift
//  Kinovechor
//
//  Created by Свят on 24.10.26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie : Movie
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: Poster
                    HStack {
                        Spacer()
                        AsyncImage(url: movie.posterURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 180, height: 270)
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 180, height: 270)
                                    .cornerRadius(12)
                                    .shadow(radius: 8)
                            case .failure(_):
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 180, height: 270)
                                    .overlay(Image(systemName: "film").font(.largeTitle).foregroundColor(.secondary))
                                
                            @unknown default:
                                EmptyView()
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    // MARK: Title and main description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            Label(movie.year, systemImage: "calendar")
                                .foregroundColor(.secondary)
                            
                            if let rating = movie.voteAverage, rating > 0 {
                                Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                    .foregroundColor(.yellow)
                                    .bold()
                            }
                        }
                        .font(.subheadline)
                    }
                    
                    Divider()
                    
                    // MARK: Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("О фильме")
                            .font(.headline)
                        
                        Text(movie.overview?.isEmpty == false ? movie.overview! : "Описание на русском языке отсудствует")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MovieDetailView(movie: Movie(id: 0, title: "Мстители", overview: "Овервью", posterPath: "", releaseDate: "2026", voteAverage: 8.2))
}
