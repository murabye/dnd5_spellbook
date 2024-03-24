//
//  UniversalTag.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 18.12.2023.
//

import SwiftUI

struct UniversalTagView: View {
    let tagProps: UniversalTagProps
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tagProps.title.lowercased())
                .lineLimit(1)
                .foregroundStyle(tagProps.foregroundColor)
            if tagProps.isActionable {
                Image(systemName: "plus")
                    .rotationEffect(tagProps.isActive ? .degrees(45) : .degrees(0))
                    .foregroundStyle(tagProps.foregroundColor)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .clipShape(Rectangle())
        .background(tagProps.isActive ? tagProps.backgroundColor : tagProps.backgroundColor.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    UniversalTagView(
        tagProps: UniversalTagProps(
            title: "1 ур", 
            isActive: false,
            foregroundColor: .black,
            backgroundColor: .teal,
            isActionable: false
        )
    )
}

struct UniversalTagProps: Identifiable, Hashable {
    
    var id: String {
        return title
    }
            
    let title: String
    let isActive: Bool
    let foregroundColor: Color
    let backgroundColor: Color
    let isActionable: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
