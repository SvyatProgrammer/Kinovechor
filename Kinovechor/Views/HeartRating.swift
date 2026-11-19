//
//  StarRating.swift
//  Kinovechor
//
//  Created by Свят on 10.11.26.
//

import SwiftUI

struct HeartRating: View {
    static let heartFillSystemName = "heart.fill"
    static let heartSystemName = "heart"
    
    @Binding var rating : Double
    var interactable = true
    var maxRating : Int = 10
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= Int(rating) ? HeartRating.heartFillSystemName : HeartRating.heartSystemName)
                    .font(.title2)
                    .foregroundColor(index <= Int(rating) ? HeartRating.heartColor(rating: rating) : .gray)
                    .onTapGesture {
                        rating = Double(index)
                    }
                    .disabled(!interactable)
            }
        }
    }
    
    static func heartColor(rating : Double) -> Color {
        if rating <= 3.0 {
            return .red
        } else if rating > 3.0, rating <= 7.0 {
            return .orange
        } else {
            return .green
        }
    }
    
}
