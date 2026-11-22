//
//  GroupFilterChip.swift
//  Kinovechor
//
//  Created by Свят on 19.11.26.
//

import SwiftUI

struct GroupFilterChip: View {
    let title : String
    let tint : Color
    let isSelected : Bool
    let action : () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(isSelected ? tint : Color(.secondarySystemBackground)))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GroupFilterChip(title: "Marvel", tint: .red, isSelected: true, action: { })
}
