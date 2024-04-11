//
//  TagSelectView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 09.04.2024.
//

import Foundation
import SwiftData
import SwiftUI
import MCEmojiPicker

struct TagSelectView: View {

    @Environment(\.modelContext) var modelContext

    @Binding var selectedTags: [Tag]
    @Query(sort: \Tag.text) var allTags: [Tag]

    @State var newTagDescription = String()
    
    @State var emoji: String = "🤠"
    @State var isEmojiPickerPresented: Bool = false
    @State var tagColor = TagColor.darkBlue
    @State var isColorPickerPresented: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                FlowLayout {
                    ForEach(allTags, id: \.id) { tag in
                        TagView(
                            compact: false,
                            edit: false,
                            tagType: TagType(
                                tag: tag,
                                removable: false,
                                muted: !selectedTags.contains(tag)
                            )
                        )
                        .onTapGesture {
                            if let index = selectedTags.firstIndex(of: tag) {
                                selectedTags.remove(at: index)
                            } else {
                                selectedTags.append(tag)
                            }
                        }
                    }
                }
                .padding()
                
                Divider()
                HStack {
                    tagColor.backgroundColor.colorWheelStyle()
                        .onTapGesture {
                            isColorPickerPresented.toggle()
                        }
                        .popover(isPresented: $isColorPickerPresented) {
                            TagColorsGallery(selected: $tagColor)
                        }
                    
                    Button(emoji) {
                        isEmojiPickerPresented.toggle()
                    }.emojiPicker(
                        isPresented: $isEmojiPickerPresented,
                        selectedEmoji: $emoji
                    )
                    
                    TextField("New tag name", text: $newTagDescription)
                    Button("", systemImage: "plus.circle.fill") {
                        createAndSetTag()
                    }
                    .disabled(newTagDescription.isEmpty)
                    .tint(.green)
                }
                .padding()
            }
        }
        .background(.ultraThickMaterial)
        .frame(idealWidth: 400)
    }
    
    func createAndSetTag() {
        let tag = Tag(
            id: UUID().uuidString,
            text: newTagDescription,
            emoji: emoji,
            isCustom: true,
            color: tagColor
        )
        modelContext.insert(tag)
        try? modelContext.save()
        selectedTags.append(tag)
    }
}
