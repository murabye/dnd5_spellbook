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
    @State var creationPresented: Bool = false
    @Binding var tags: [Tag]
    var onAdd: (() -> Void)? = nil

    var body: some View {
        FlowLayout {
            ForEach(tags, id: \.id) { tag in
                TagView(compact: compact, edit: edit, tagType: TagType(tag: tag, removable: edit))
                    .gesture(edit ? TapGesture().onEnded { [weak tag] in tags.removeAll { $0.id == tag?.id } } : nil)
            }
    
            if let onAdd {
                TagView(
                    compact: true,
                    edit: edit,
                    tagType: TagType(
                        id: "plus",
                        removable: false,
                        name: "",
                        color: .blend(color1: .gray, intensity: 0.2, color2: .white),
                        textColor: .black,
                        emoji: "➕"
                    )
                )
                .onTapGesture { onAdd() }
            }
        }
    }
}
