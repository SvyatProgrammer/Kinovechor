//
//  LibraryFilterSheetView.swift
//  Kinovechor
//
//  Created by Свят on 22.11.26.
//

import SwiftUI

struct LibraryFilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    let items : [LibraryItem]
    
    @Binding var selectedStatus : WatchStatus?
    @Binding var selectedYear : String?
    @Binding var selectedMediaType: String?
    @Binding var selectedGenreId: Int?
    @Binding var minVoteText: String
    @Binding var maxVoteText: String
    @Binding var minRatingText: String
    @Binding var maxRatingText: String
    
    private var years : [String] {
        Array(Set(items.map(\.year).filter { $0 != "Н/Д" && !$0.isEmpty })).sorted(by: >)
    }
    
    private var genres : [(id : Int, name : String)] {
        let ids = Set(items.compactMap(\.genreIds).flatMap { $0 })
        return ids.compactMap { id in
            Genre.genreMap[id].map { (id : id, name : $0) }
        }
        .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Статус", selection: $selectedStatus) {
                    Text("Все").tag(WatchStatus?.none)
                    ForEach(WatchStatus.allCases) { status in
                        Text(status.id).tag(WatchStatus?.some(status))
                    }
                }
                
                Picker("Год", selection: $selectedYear) {
                    Text("Все").tag(String?.none)
                    ForEach(years, id: \.self) { year in
                        Text(year).tag(String?.some(year))
                    }
                }
                
                Picker("Тип", selection: $selectedMediaType) {
                    Text("Все").tag(String?.none)
                    Text("Фильм").tag(String?.some("movie"))
                    Text("Сериал").tag(String?.some("tv"))
                }
                
                Picker("Жанр", selection: $selectedGenreId) {
                    Text("Все").tag(Int?.none)
                    ForEach(genres, id: \.id) { genre in
                        Text(genre.name).tag(Int?.some(genre.id))
                    }
                }
                
                Section("Рейтинг") {
                    HStack {
                        Picker("От", selection: $minVoteText) {
                            Text("От: любой").tag(String?.none)
                            ForEach(1...10, id: \.self) { n in
                                Text("От \(n)").tag("\(n)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        
                        Picker("До", selection: $maxVoteText) {
                            Text("До: любой").tag(String?.none)
                            ForEach(1...10, id: \.self) { n in
                                Text("До \(n)").tag("\(n)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                }
                
                Section("Рейтинг комнаты") {
                    HStack {
                        Picker("От", selection: $minRatingText) {
                            Text("От: любой").tag(String?.none)
                            ForEach(1...10, id: \.self) { n in
                                Text("От \(n)").tag("\(n)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        
                        Picker("До", selection: $maxRatingText) {
                            Text("До: любой").tag(String?.none)
                            ForEach(1...10, id: \.self) { n in
                                Text("До \(n)").tag("\(n)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                }
                
                Button("Сбросить", role: .destructive) {
                    selectedStatus = nil
                    selectedYear = nil
                    selectedMediaType = nil
                    selectedGenreId = nil
                    minVoteText = ""
                    maxVoteText = ""
                    minRatingText = ""
                    maxRatingText = ""
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    @Previewable @State var selectedStatus: WatchStatus? = nil
    @Previewable @State var selectedYear: String? = nil
    @Previewable @State var selectedMediaType: String? = nil
    @Previewable @State var selectedGenreId: Int? = nil
    @Previewable @State var minVoteText: String = ""
    @Previewable @State var maxVoteText: String = ""
    @Previewable @State var minRatingText: String = ""
    @Previewable @State var maxRatingText: String = ""

    let sampleItems: [LibraryItem] = [
        LibraryItem(
            id: 550,
            title: "Бойцовский клуб",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            mediaType: "movie",
            year: "1999",
            voteAverage: 8.4,
            genreIds: [18, 53],
            overview: "Страховой работник страдает от хронической бессонницы...",
            status: "Просмотрено",
            group: "Основная",
            comment: "Отличный фильм"
        ),
        LibraryItem(
            id: 1396,
            title: "Во все тяжкие",
            posterPath: "/ggFHVNu6YYI5L9pCfOacjizRGt.jpg",
            mediaType: "tv",
            year: "2008",
            voteAverage: 8.9,
            genreIds: [18, 80],
            overview: "Учитель химии Уолтер Уайт узнает, что болен раком...",
            status: "Смотрим",
            group: "Основная",
            comment: ""
        ),
        LibraryItem(
            id: 299534,
            title: "Мстители: Финал",
            posterPath: "/or06FN3Dka5tukK1e9sl16pB3iy.jpg",
            mediaType: "movie",
            year: "2019",
            voteAverage: 8.3,
            genreIds: [12, 878, 28],
            overview: "Оставшиеся в живых члены команды Мстителей...",
            status: "В планах",
            group: "Marvel",
            comment: ""
        )
    ]

    LibraryFilterSheetView(
        items: sampleItems,
        selectedStatus: $selectedStatus,
        selectedYear: $selectedYear,
        selectedMediaType: $selectedMediaType,
        selectedGenreId: $selectedGenreId,
        minVoteText: $minVoteText,
        maxVoteText: $maxVoteText,
        minRatingText: $minRatingText,
        maxRatingText: $maxRatingText
    )
}
