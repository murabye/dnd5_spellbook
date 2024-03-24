//
//  FilterExpandableContent.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 18.12.2023.
//

import SwiftUI

struct FilterExpandableContent<E: RawRepresentable>: View where E:  FilterFormSelectable {
    @Binding var isOpened: Bool
    @Binding var active: [E]
    var sources: [E]
    var filter: (E) -> Bool
    
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
                    title: source.name,
                    isActive: isActive,
                    foregroundColor: .white,
                    backgroundColor: .gray,
                    isActionable: true
                )
            })
            Spacer()
        }
        .clipShape(Rectangle())
    }
}
