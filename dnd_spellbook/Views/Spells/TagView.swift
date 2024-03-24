//
//  TagLine.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.12.2023.
//

import SwiftUI

struct TagView: View {
    let compact: Bool
    let edit: Bool
    let tagType: TagType
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tagType.emoji)
                .foregroundStyle(tagType.textColor)
                .background(tagType.color)
                .clipShape(Rectangle())
                .clipped()
                .zIndex(1.0)
            if !compact && !tagType.name.isEmpty {
                Text(tagType.name.lowercased())
                    .foregroundStyle(tagType.textColor)
                    .transition(
                        .move(edge: .leading)
                        .combined(with: .opacity)
                    )
            }
            if edit && tagType.removable {
                Image(systemName: "xmark")
                    .foregroundStyle(tagType.textColor)
            } else if !compact {
                Spacer().frame(width: 4)
            }
        }
        .clipShape(Capsule())
        .clipped()
        .padding(.vertical, 6)
        .padding(.horizontal, !compact && edit && tagType.removable ? 8 : 6)
        .background(tagType.color)
        .clipShape(Capsule())
        .animation(.easeIn, value: edit)
    }
}

//#Preview {
//    TagView(compact: false, edit: false, tagType: .heal)
//}

struct TagType: Identifiable {

    let id: String
    let removable: Bool
    let name: String
    let color: Color
    let textColor: Color
    let emoji: String
    
    init(
        id: String,
        removable: Bool,
        name: String, 
        color: Color,
        textColor: Color,
        emoji: String
    ) {
        self.id = id
        self.removable = removable
        self.name = name
        self.color = color
        self.textColor = textColor
        self.emoji = emoji
    }
    
    init(
        tag: Tag,
        removable: Bool
    ) {
        self.id = tag.id
        self.removable = removable
        self.name = tag.text
        self.color = tag.color.backgroundColor
        self.textColor = tag.color.foregroundColor
        self.emoji = tag.emoji
    }

}
