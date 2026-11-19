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
    
    private var filtredItems : [LibraryItem] {
        guard let selectedGroup else {
            return roomManager.roomLibraryItems
        }
        return roomManager.roomLibraryItems.filter { $0.group == selectedGroup.id }
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
        }
    }
    
    private var groupFiltedBar : some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
