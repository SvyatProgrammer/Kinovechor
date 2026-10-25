//
//  MovieRow.swift
//  Kinovechor
//
//  Created by Свят on 25.10.26.
//

import SwiftUI

struct MovieRow: View {
    let movie : Movie
    let onTab: () -> Void
    
    var body: some View {
        Button(action: onTab) {
            HStack(spacing: 16) {
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(width: 60, height: 90)
                            .overlay(ProgressView().scaleEffect(0.7))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 90)
                            .cornerRadius(8)
                    case .failure(_):
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(width: 60, height: 90)
                            .overlay(Image(systemName: "film").foregroundColor(.secondary))
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
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
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}
