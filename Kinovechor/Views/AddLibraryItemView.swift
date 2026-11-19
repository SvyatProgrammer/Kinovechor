//
//  AddEditLibraryItemView.swift
//  Kinovechor
//
//  Created by Свят on 9.11.26.
//

import SwiftUI

struct AddLibraryItemView : View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var roomManager : RoomManager
    
    let movie : Movie
    
    @State private var status : String = WatchStatus.planned.id
    @State private var group : String = GroupType.main.id
    @State private var comment : String = ""
    @State private var rating : Double = 8.0
    
    @State private var season : Int = 1
    @State private var episode : Int = 1
    @State private var hours : Int = 0
    @State private var minutes : Int = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Информация") {
                    HStack(spacing: 16) {
                        AsyncImage(url: movie.posterURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .overlay(ProgressView().scaleEffect(0.7))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_):
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .overlay(Image(systemName: "film").foregroundColor(.secondary))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 50, height: 75)
                        .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(movie.displayTitle)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                if movie.mediaType == "tv" {
                                    Text("Сериал")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(4)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                Text(movie.year)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .foregroundStyle(.secondary)
                                
                                if let rating = movie.voteAverage, rating > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                            .font(.caption)
                                        Text(String(format: "%.1f", rating))
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section("Настройки комнаты") {
                    Picker("Статус", selection: $status) {
                        ForEach(WatchStatus.statuses, id: \.self) { st in
                            Text(st)
                        }
                    }
                    
                    Picker("Группа", selection: $group) {
                        ForEach(GroupType.groups, id: \.self) { gp in
                            Text(gp)
                        }
                    }
                }
                
                if status == WatchStatus.watching.id {
                    Section("Где остановились") {
                        if movie.mediaType == "tv" {
                            HStack {
                                Picker("Сезон", selection: $season) {
                                    ForEach(1...200, id: \.self) { number in
                                        Text("Сезон \(number)")
                                            .tag(number)
                                    }
                                }
                                .pickerStyle(.wheel)
                                Picker("Серия", selection: $episode) {
                                    ForEach(1...1000, id: \.self) { number in
                                        Text("Серия \(number)")
                                            .tag(number)
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                        } else {
                            HStack {
                                Picker("Час", selection: $hours) {
                                    ForEach(0...5, id: \.self) { number in
                                        Text("Час \(number)")
                                            .tag(number)
                                    }
                                }
                                .pickerStyle(.wheel)
                                
                                Picker("Минута", selection: $minutes) {
                                    ForEach(1...60, id: \.self) { number in
                                        Text("Минута \(number)")
                                            .tag(number)
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                        }
                    }
                }
                
                if status == WatchStatus.watched.id {
                    Section("Оценка компании") {
                        HStack {
                            Image(systemName: HeartRating.heartFillSystemName)
                                .foregroundColor(HeartRating.heartColor(rating: rating))
                            Text("\(rating, specifier: "%.0f") / 10")
                        }
                        .frame(maxWidth: .infinity)
                        .font(.title2)
                        .bold()
                        HStack {
                            Spacer()
                            HeartRating(rating: $rating)
                            Spacer()
                        }
                    }
                }
                
                Section("Комментарий") {
                    ZStack {
                        TextEditor(text: $comment)
                            .frame(height: 80)
                        
                        if comment.isEmpty {
                            Text("Пусто")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Добавить")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let totalMinutes = (hours * 60) + minutes
                        
                        let newItem = LibraryItem(
                            id: movie.id,
                            title: movie.displayTitle,
                            posterPath: movie.posterPath,
                            mediaType: movie.mediaType,
                            year: movie.year,
                            voteAverage: movie.voteAverage,
                            genreIds: movie.genreIds,
                            overview: movie.overview,
                            status: status,
                            group: group.isEmpty ? GroupType.main.id : group,
                            comment: comment,
                            rating: status == WatchStatus.watched.id ? rating : nil,
                            watchedSeason: (status == WatchStatus.watching.id && movie.mediaType == "tv") ? season : nil,
                            watchedEpisode: (status == WatchStatus.watching.id && movie.mediaType == "tv") ? episode : nil,
                            watchedMinutes: (status == WatchStatus.watching.id && movie.mediaType != "tv") ? totalMinutes : nil
                        )
                        
                        roomManager.saveItemToLibrary(item: newItem) { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddLibraryItemView(movie: Movie(id: 0, title: "Test", name: "Test", overview: "SomeTest", posterPath: "/7ABzbWhBzp4YjkXziGl77HmPa1h.jpg", releaseDate: "2027", firstAirDate: "2027", voteAverage: 9.0, mediaType: "movie", genreIds: [9], genres: nil))
        .environmentObject(RoomManager())
}
