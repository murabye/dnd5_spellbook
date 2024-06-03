//
//  SpellListView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct SpellListView: View {
    @Binding var spells: [Spell]
    @Binding var character: CharacterModel?

    var canEdit: Bool = true
    let name: SectionsNames
    var onHide: (Spell) -> Void
    var onUnhide: (Spell) -> Void
    var onRemove: (Spell) -> Void
    var onKnow: (Spell) -> Void
    var onUnknow: (Spell) -> Void
    var onPrepare: (Spell) -> Void
    var onUnprepare: (Spell) -> Void

    var body: some View {
        ForEach(
            $spells,
            id: \.id
        ) { spell in
            SetuppedSpellView(
                spell: spell,
                editingSpell: nil,
                character: $character,
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
    }
}
