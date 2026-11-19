//
//  EditLibraryItemView.swift
//  Kinovechor
//
//  Created by Свят on 14.11.26.
//

import SwiftUI

struct EditLibraryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var roomManager : RoomManager
    
    let item : LibraryItem
    
    @State private var status : String
    @State private var group : String
    @State private var comment : String
    @State private var rating : Double
    
    @State private var season : Int
    @State private var episode : Int
    @State private var hours : Int
    @State private var minutes : Int
    
    init(item : LibraryItem) {
        self.item = item
        
        _status = State(initialValue: item.status)
        _group = State(initialValue: item.group)
        _comment = State(initialValue: item.comment)
        _rating = State(initialValue: item.rating ?? 0.0)
        _season = State(initialValue: item.watchedSeason ?? 1)
        _episode = State(initialValue: item.watchedEpisode ?? 1)
        
        let totalMinutes = item.watchedMinutes ?? 0
        _hours = State(initialValue: totalMinutes / 60)
        _minutes = State(initialValue: totalMinutes % 60)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Информация") {
                    HStack(spacing: 16) {
                        AsyncImage(url: item.posterURL) { phase in
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
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                if item.mediaType == "tv" {
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
                                Text(item.year)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .foregroundStyle(.secondary)
                                
                                if let rating = item.voteAverage, rating > 0 {
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
                        if item.mediaType == "tv" {
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
            .navigationTitle("Изменить")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if roomManager.isUpdateLibraryItem {
                        ProgressView()
                    } else {
                        Button("Сохранить") {
                            let totalMinutes = (hours * 60) + minutes
                            
                            let newItem = LibraryItem(
                                id: item.id,
                                title: item.title,
                                posterPath: item.posterPath,
                                mediaType: item.mediaType,
                                year: item.year,
                                voteAverage: item.voteAverage,
                                genreIds: item.genreIds,
                                overview: item.overview,
                                status: status,
                                group: group.isEmpty ? GroupType.main.id : group,
                                comment: comment,
                                rating: status == WatchStatus.watched.id ? rating : nil,
                                watchedSeason: (status == WatchStatus.watching.id && item.mediaType == "tv") ? season : nil,
                                watchedEpisode: (status == WatchStatus.watching.id && item.mediaType == "tv") ? episode : nil,
                                watchedMinutes: (status == WatchStatus.watching.id && item.mediaType != "tv") ? totalMinutes : nil
                            )
                            
                            roomManager.updateLibraryItem(item: newItem) { success in
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
}

#Preview {
    EditLibraryItemView(item: LibraryItem(id: 1, title: "Test", posterPath: "", mediaType: "tv", year: "2027", voteAverage: 7.7, genreIds: [12], overview: "Some overview", status: WatchStatus.planned.id, group: GroupType.marvel.id, comment: "Some comment"))
        .environmentObject(RoomManager())
}
