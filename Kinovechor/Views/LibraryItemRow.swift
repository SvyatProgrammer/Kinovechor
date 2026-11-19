//
//  LibraryItemRow.swift
//  Kinovechor
//
//  Created by Свят on 10.11.26.
//

import SwiftUI

struct LibraryItemRow : View {
    @EnvironmentObject var roomManager : RoomManager
    var item : LibraryItem
    
    var body: some View {
        NavigationLink(destination: LibraryDetailView(initialItem: item)
            .environmentObject(roomManager)
        ) {
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
                .frame(width: 60, height: 90)
                .cornerRadius(8)
                
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
                        
                        if let rating = item.rating, rating > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: HeartRating.heartFillSystemName)
                                    .foregroundStyle(HeartRating.heartColor(rating: rating))
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Spacer()
                        
                        Text(item.status)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(WatchStatus.color(for: item.status).opacity(0.2))
                            .foregroundColor(WatchStatus.color(for: item.status))
                            .cornerRadius(4)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    LibraryItemRow(item: LibraryItem(id: 0, title: "Test", posterPath: "/7ABzbWhBzp4YjkXziGl77HmPa1h.jpg", mediaType: "tv", year: "2027", voteAverage: 6.3, genreIds: [1,2,3], overview: "Some overview", status: WatchStatus.planned.id, group: GroupType.main.id, comment: "Some comment"))
        .environmentObject(RoomManager())
}
