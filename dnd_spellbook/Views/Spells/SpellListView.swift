//
//  SpellListView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct SpellListView: View {
    @Binding var spellsByLevel: [Int: [Spell]]
    @Binding var character: CharacterModel?
    
    @Binding var preparedSpellsMap: [String: Bool]
    @Binding var knownSpellsMap: [String: Bool]

    let pinIndex: Int
    
    var canEdit: Bool = true
    let name: SectionsName
    var onHide: (Spell) -> Void
    var onUnhide: (Spell) -> Void
    var onRemove: (Spell) -> Void
    var onKnow: (Spell) -> Void
    var onUnknow: (Spell) -> Void
    var onPrepare: (Spell) -> Void
    var onUnprepare: (Spell) -> Void

    @ViewBuilder
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0...9, id: \.self) { level in
                if let spells = spellsByLevel[level], !spells.isEmpty {
                    SpellCellsHeaderView(character: $character, cellLevel: level).pinned(index: pinIndex)
                    ForEach(spells, id: \.id) { spell in
                        SetuppedSpellView(
                            spell: spell,
                            editingSpell: nil,
                            character: $character,
                            preparedSpellsMap: $preparedSpellsMap,
                            knownSpellsMap: $knownSpellsMap,
                            canEdit: canEdit,
                            name: name,
                            onHide: onHide,
                            onUnhide: onUnhide,
                            onRemove: onRemove,
                            onKnow: onKnow,
                            onUnknow: onUnknow,
                            onPrepare: onPrepare,
                            onUnprepare: onUnprepare
                        )
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}
