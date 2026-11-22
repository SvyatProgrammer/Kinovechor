//
//  ReviewDetailView.swift
//  Kinovechor
//
//  Created by Свят on 26.10.26.
//

import SwiftUI

struct ReviewDetailView: View {
    let review : Rewiew
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: Author and rating
                    HStack {
                        Text(review.author)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if let rating = review.authorDetails?.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(Int(rating))/10")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: Full description
                    Text(review.content)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Полный отзыв")
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
    ReviewDetailView(review: Rewiew(id: "1", author: "Svyat", content: "This is test content where show test message", createdAt: "2026-01-01", authorDetails: AuthorDetails(rating: 8.6)))
}
