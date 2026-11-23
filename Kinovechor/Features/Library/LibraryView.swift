//
//  LibraryView.swift
//  Kinovechor
//
//  Created by Свят on 5.11.26.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var roomManager : RoomManager
    
    @State private var selectedGroup : GroupType? = nil
    @State private var showFilterSheet = false
    
    // Filter params
    @State private var selectedStatus : WatchStatus? = nil
    @State private var selectedYear : String? = nil
    @State private var selectedMediaType : String? = nil
    @State private var selectedGenreId : Int? = nil
    @State private var minVoteText = ""
    @State private var maxVoteText = ""
    @State private var minRatingText = ""
    @State private var maxRatingText = ""
    
    // Sort params
    @State private var sortOption : SortOption = .defaultOrder
    
    private var filtredItems : [LibraryItem] {
        let minVote = Double(minVoteText.replacingOccurrences(of: ",", with: "."))
        let maxVote = Double(maxVoteText.replacingOccurrences(of: ",", with: "."))
        let minRating = Double(minRatingText.replacingOccurrences(of: ",", with: "."))
        let maxRating = Double(maxRatingText.replacingOccurrences(of: ",", with: "."))
        
        let filtred = roomManager.roomLibraryItems.filter { item in
            if let selectedGroup, item.group != selectedGroup.id { return false }
            if let selectedStatus, item.status != selectedStatus.id { return false }
            if let selectedYear, item.year != selectedYear { return false }
            
            if let selectedMediaType {
                let type = item.mediaType ?? "movie"
                if type != selectedMediaType { return false }
            }
            
            if let selectedGenreId {
                guard let ids = item.genreIds, ids.contains(selectedGenreId) else { return false }
            }
            
            if let minVote {
                guard let vote = item.voteAverage, vote >= minVote else { return false }
            }
            if let maxVote {
                guard let vote = item.voteAverage, vote <= maxVote else { return false }
            }
            
            if let minRating {
                guard let rating = item.rating, rating > 0, rating >= minRating else { return false }
            }
            if let maxRating {
                guard let rating = item.rating, rating > 0, rating <= maxRating else { return false }
            }
            
            return true
        }
        
        switch sortOption {
        case .defaultOrder:
            return filtred
        case .titleAsc:
            return filtred.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        case .titleDesc:
            return filtred.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedDescending
            }
        case .tmdbRating:
            return filtred.sorted {
                ($0.voteAverage ?? -1) > ($1.voteAverage ?? -1)
            }
        case .roomRating:
            return filtred.sorted {
                ($0.rating ?? -1) > ($1.rating ?? -1)
            }
        }
    }
    
    private var hasActiveFilters : Bool {
        selectedStatus != nil ||
        selectedYear != nil ||
        selectedMediaType != nil ||
        selectedGenreId != nil ||
        !minVoteText.isEmpty ||
        !maxVoteText.isEmpty ||
        !minRatingText.isEmpty ||
        !maxRatingText.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if roomManager.currentRoomId == nil {
                    Text("Вы не состоите в комнате")
                        .foregroundColor(.secondary)
                } else if roomManager.isFetchRoomLibrary {
                    ProgressView()
                } else if roomManager.roomLibraryItems.isEmpty {
                    Text("Библиотека комнаты пуста.\nДобавьте фильмы из списка свайпом вправо.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack {
                        groupFiltedBar
                        
                        if filtredItems.isEmpty {
                            Spacer()
                            Text("В группе «\(selectedGroup?.rawValue ?? "")» пока нет фильмов")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        } else {
                            List {
                                ForEach(filtredItems) { item in
                                    LibraryItemRow(item: item)
                                        .environmentObject(roomManager)
                                }
                                .onDelete { indexSet in
                                    indexSet.forEach { index in
                                        let item = filtredItems[index]
                                        roomManager.removeItemFromLibrary(itemId: item.id) { _ in }
                                    }
                                }
                            }
                            .refreshable {
                                roomManager.fetchRoomLibrary()
                            }
                            .listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Фильмотека")
            .onAppear {
                roomManager.fetchRoomLibrary()
            }
            .sheet(isPresented: $showFilterSheet) {
                LibraryFilterSheetView(items: filtredItems, selectedStatus: $selectedStatus, selectedYear: $selectedYear, selectedMediaType: $selectedMediaType, selectedGenreId: $selectedGenreId, minVoteText: $minVoteText, maxVoteText: $maxVoteText, minRatingText: $minRatingText, maxRatingText: $maxRatingText)
            }
        }
    }
    
    private var groupFiltedBar : some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Filter button
                Button(action: {
                    showFilterSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        Text("Фильтры")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule()
                        .fill(hasActiveFilters ? Color.accentColor : Color(.secondarySystemBackground)))
                    .foregroundStyle(hasActiveFilters ? Color.white : Color.primary)
                }
                .buttonStyle(.plain)
                
                // Sort button
                Menu {
                    Picker("Сортировка", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.id).tag(option)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        if sortOption != .defaultOrder {
                            Text(sortOption.id)
                        }
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(sortOption != .defaultOrder ? Color.accentColor : Color(.secondarySystemBackground))
                    )
                    .foregroundStyle(sortOption != .defaultOrder ? Color.white : Color.primary)
                }
                
                // Groups
                GroupFilterChip(title: "Все", tint: .accentColor, isSelected: selectedGroup == nil) {
                    selectedGroup = nil
                }
                
                ForEach(GroupType.allCases) { group in
                    GroupFilterChip(title: group.id, tint: group.color, isSelected: selectedGroup == group) {
                        selectedGroup = (selectedGroup == group) ? nil : group
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(RoomManager())
}
