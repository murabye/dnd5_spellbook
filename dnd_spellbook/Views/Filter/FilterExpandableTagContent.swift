//
//  FilterExpandableContent.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 18.12.2023.
//

import SwiftUI

struct FilterExpandableTagContent: View {
    @Binding var isOpened: Bool
    @Binding var active: [Tag]
    var sources: [Tag]
    var filter: (Tag) -> Bool
    
    var body: some View {
        HStack {
            UniversalTagLine(onDelete: { index in
                guard isOpened else {
                    active.remove(at: index)
                    return
                }
                if let index = active.firstIndex(of: sources[index]) {
                    active.remove(at: index)
                } else {
                    active.append(sources[index])
                }
            }, tags: sources
                .filter { filter($0) }
                .map { source in
                let isActive = active.contains(source)
                return UniversalTagProps(
                    title: "\(source.emoji) \(source.text)",
                    isActive: isActive,
                    foregroundColor: source.color.foregroundColor,
                    backgroundColor: source.color.backgroundColor,
                    isActionable: true
                )
            })
            Spacer()
        }
        .clipShape(Rectangle())
    }
}
