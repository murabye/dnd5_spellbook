//
//  TagLine.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.12.2023.
//

import SwiftUI

struct TagLine: View {
    let compact: Bool
    let edit: Bool
    let tags: [TagType]
    
    init(compact: Bool, edit: Bool, tags: [TagType]) {
        self.compact = compact
        self.tags = tags
        self.edit = edit
    }

    init(compact: Bool, edit: Bool, tags: [Tag]) {
        self.compact = compact
        self.edit = edit
        var userTags = tags
            .sorted()
            .map { TagType(tag: $0, removable: true) }
        if edit {
            userTags.append(
                TagType(
                    id: "plus",
                    removable: false,
                    name: "",
                    color: .blend(color1: .gray, intensity: 0.2, color2: .white),
                    textColor: .black,
                    emoji: "➕"
                )
            )
        }
        self.tags = userTags
    }
    
    var body: some View {
        FlowLayout {
            ForEach(tags) {
                TagView(compact: compact, edit: edit, tagType: $0)
            }
        }
    }
}

//#Preview {
//    TagLine(compact: false, edit: true, tags: [
//        .new
//    ])
//}
