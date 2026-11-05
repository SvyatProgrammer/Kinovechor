//
//  MovieDetailView.swift
//  Kinovechor
//
//  Created by Свят on 24.10.26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie : Movie
    @StateObject private var tmdbManager = TMDBManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReview : Rewiew? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                
                    // MARK: Poster
                    posterSection
                    
                    // MARK: Title and main description
                    headerInfoSection
                    
                    Divider()
                    
                    // MARK: Credits
                    creditsSection
                    
                    Divider()
                    
                    // MARK: Description
                    descriptionSection
                    
                    Divider()
                    
                    // MARK: Reviews
                    reviewSection
                    
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
            .onAppear {
                tmdbManager.fetchMovieData(movieId: movie.id, mediaType: movie.mediaType)
            }
            .sheet(item: $selectedReview) { review in
                ReviewDetailView(review: review)
            }
        }
    }
}

extension MovieDetailView {
    private var posterSection : some View {
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
    }
    
    private var headerInfoSection : some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.displayTitle)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                Label(movie.year, systemImage: "calendar")
                    .foregroundColor(.secondary)
                
                if let rating = movie.voteAverage, rating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .bold()
                    }
                }
            }
            .font(.subheadline)
            
            if movie.mediaType == "tv" {
                HStack(spacing: 12) {
                    if let seasons = tmdbManager.numberOfSeasons {
                        Label("\(seasons) \(seasonsText(seasons))", systemImage: "tv")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let episodes = tmdbManager.numberOfEpisodes {
                        Label("\(episodes) \(episodesText(episodes))", systemImage: "film.stack")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            HStack(spacing: 6) {
                Text(movie.mediaType == "movie" ? "Режиссер:" : "Создатель / Режиссер:") 
                    .foregroundColor(.secondary)
                Text(tmdbManager.director)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .padding(.top, 2)
            
            if !movie.genreNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(movie.genreNames, id: \.self) { genreName in
                            Text(genreName)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }
    
    private var creditsSection : some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("В главных ролях")
                .font(.headline)
            
            if tmdbManager.isLoadingCasts {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if tmdbManager.cast.isEmpty {
                Text("Информация об актерах отсутствует")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(tmdbManager.cast) { actor in
                            VStack(alignment: .center, spacing: 6) {
                                
                                // Image of actor
                                AsyncImage(url: actor.profileURL) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle()
                                            .fill(Color(.systemGray6))
                                            .frame(width: 80, height: 110)
                                            .overlay(ProgressView())
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 110)
                                            .cornerRadius(8)
                                    case .failure(_):
                                        Rectangle()
                                            .fill(Color(.systemGray6))
                                            .frame(width: 80, height: 110)
                                            .cornerRadius(8)
                                            .overlay(Image(systemName: "person.fill").foregroundColor(.secondary))
                                    default:
                                        Rectangle()
                                            .fill(Color(.systemGray6))
                                            .frame(width: 80, height: 110)
                                            .cornerRadius(8)
                                            .overlay(Image(systemName: "person.fill").foregroundColor(.secondary))
                                    }
                                }
                                
                                // Name of actor
                                Text(actor.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80)
                                
                                // Name of character
                                if let character = actor.character, !character.isEmpty {
                                    Text(character)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .frame(width: 80)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var descriptionSection : some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.mediaType == "movie" ? "О фильме" : "О сериале")
                .font(.headline)
            
            Text(movie.overview?.isEmpty == false ? movie.overview! : "Описание на русском языке отсутствует")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    private var reviewSection : some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Отзовы зрителей")
                .font(.headline)
            
            if tmdbManager.reviews.isEmpty, tmdbManager.isLoafingReviews {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if tmdbManager.reviews.isEmpty {
                Text("Пока нет отзывов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(tmdbManager.reviews) { review in
                    reviewCard(review: review)
                }
            }
        }
    }
    
    private func reviewCard(review: Rewiew) -> some View {
        Button(action: {
            selectedReview = review
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(review.author)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if let rating = review.authorDetails?.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                            Text("\(Int(rating))/10")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text(review.content)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func seasonsText(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder100 >= 11 && remainder100 <= 19 { return "сезонов" }
        if remainder10 == 1 { return "сезон" }
        if remainder10 >= 2 && remainder10 <= 4 { return "сезона" }
        return "сезонов"
    }
    
    private func episodesText(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder100 >= 11 && remainder100 <= 19 { return "серий" }
        if remainder10 == 1 { return "серия" }
        if remainder10 >= 2 && remainder10 <= 4 { return "серии" }
        return "серий"
    }
}

//#Preview {
//    MovieDetailView(movie: Movie(id: 0, title: "Мстители", overview: "Овервью", posterPath: "", releaseDate: "2026", voteAverage: 8.2))
//}
