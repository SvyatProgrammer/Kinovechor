//
//  LibraryDetailView.swift
//  Kinovechor
//
//  Created by Свят on 9.11.26.
//

import SwiftUI

struct LibraryDetailView: View {
    @EnvironmentObject var roomManager : RoomManager
    @StateObject private var tmdbManager = TMDBManager()
    let initialItem : LibraryItem
    
    private var item : LibraryItem {
        roomManager.roomLibraryItems.first { $0.id == initialItem.id } ?? initialItem
    }
    
    @State private var isEditing = false
    @State private var selectedReview : Rewiew? = nil
    
    private var hours: Int {
        (item.watchedMinutes ?? 0) / 60
    }

    private var minutes: Int {
        (item.watchedMinutes ?? 0) % 60
    }
    
    private var formattedWatchTime: String {
        if hours > 0 && minutes > 0 {
            return "\(hours) ч \(minutes) мин"
        } else if hours > 0 {
            return "\(hours) ч"
        } else {
            return "\(minutes) мин"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    posterSection
                    
                    headerInfoSection
                    
                    Divider()
                    
                    creditsSection
                    
                    Divider()
                    
                    descriptionSection
                    
                    Divider()
                    
                    if item.status == WatchStatus.watching.id {
                        wheareWeStopedSection
                        
                        Divider()
                    }
                    
                    if item.status == WatchStatus.watched.id {
                        ratingSection
                        
                        Divider()
                    }
                    
                    if !item.comment.isEmpty {
                        commentSection
                        
                        Divider()
                    }
                    
                    reviewSection
                    
                    
                }
                .padding(20)
            }
            .navigationTitle(item.mediaType == "tv" ? "Детали сериала" : "Детали фильма")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Изменить") {
                        isEditing = true
                    }
                }
            }
            .onAppear {
                tmdbManager.fetchMovieData(movieId: item.id, mediaType: item.mediaType)
            }
            .sheet(item: $selectedReview) { review in
                ReviewDetailView(review: review)
            }
            .sheet(isPresented: $isEditing) {
                EditLibraryItemSheetView(item: item)
            }
        }
    }
}

extension LibraryDetailView {
    private var posterSection : some View {
        HStack {
            Spacer()
            AsyncImage(url: item.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .shadow(radius: 8)
                case .failure(_):
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .overlay(Image(systemName: "film").font(.largeTitle).foregroundColor(.secondary))
                    
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 180, height: 270)
            .cornerRadius(12)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var headerInfoSection : some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                Label(item.year, systemImage: "calendar")
                    .foregroundColor(.secondary)
                
                if item.voteAverage ?? 0.0 > 0.0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", item.voteAverage ?? 0.0))
                            .bold()
                    }
                }
                
                Text(item.status)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WatchStatus.color(for: item.status).opacity(0.2))
                    .foregroundColor(WatchStatus.color(for: item.status))
                    .cornerRadius(8)
            }
            .font(.subheadline)
            
            HStack {
                Text("Группа:")
                    .foregroundColor(.secondary)
                Text(item.group)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(GroupType.color(for: item.group).opacity(0.2))
                    .foregroundColor(GroupType.color(for: item.group))
                    .cornerRadius(8)
            }
            
            if item.mediaType == "tv" {
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
                Text(item.mediaType == "movie" ? "Режиссер:" : "Создатель / Режиссер:")
                    .foregroundColor(.secondary)
                Text(tmdbManager.director)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .padding(.top, 2)
            
            if !item.genreNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(item.genreNames, id: \.self) { genreName in
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
            Text(item.mediaType == "movie" ? "О фильме" : "О сериале")
                .font(.headline)
            
            Text(item.overview?.isEmpty == false ? item.overview! : "Описание на русском языке отсутствует")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    private var wheareWeStopedSection : some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Где остановились")
                .font(.headline)
            
            if item.mediaType == "tv" {
                HStack(spacing: 16) {
                    VStack(alignment: .center, spacing: 6) {
                        Image(systemName: "square.stack.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Сезон: \(item.watchedSeason ?? 1)")
                            .font(.headline)
                            .bold()
                    }
                    .frame(minHeight: 60)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    VStack(alignment: .center, spacing: 6) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Серия: \(item.watchedEpisode ?? 1)")
                            .font(.headline)
                            .bold()
                    }
                    .frame(minHeight: 60)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            } else {
                VStack(alignment: .center, spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text(formattedWatchTime	)
                        .font(.headline)
                        .bold()
                }
                .frame(minHeight: 60)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
    
    private var ratingSection : some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Оценка комнаты")
                .font(.headline)
            
            VStack(spacing: 8) {
                Image(systemName: HeartRating.heartFillSystemName)
                    .foregroundColor(HeartRating.heartColor(rating: item.rating ?? 0.0))
                    .font(.title)
                Text("\(item.rating ?? 0.0, specifier: "%.0f") / 10")
                    .font(.title2)
                    .bold()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var commentSection : some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Комментарий:")
                .font(.headline)
            Text(item.comment)
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

#Preview {
    LibraryDetailView(initialItem: LibraryItem(id: 0, title: "Test", posterPath: "/7ABzbWhBzp4YjkXziGl77HmPa1h.jpg", mediaType: "movie", year: "2027", voteAverage: 6.3, genreIds: [28,12,16], overview: "Some overview", status: WatchStatus.watched.id, group: GroupType.marvel.id, comment: "Test comment"))
        .environmentObject(RoomManager())
}
