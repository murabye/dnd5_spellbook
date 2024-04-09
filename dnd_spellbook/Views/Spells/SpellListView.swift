//
//  SpellListView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct SpellListView: View {
    let spells: [Spell]
    let columns: Int
//    @State var editingSpell: Spell?
    @Environment(\.modelContext) var modelContext
    @Binding var character: CharacterModel?

    var body: some View {
        VerticalWaterfallLayout(
            columns: columns,
            spacingX: 16,
            spacingY: 16
        ) {
            ForEach(
                spells,
                id: \.id
            ) { spell in
                    SpellView(
                        spell: spell,
                        collapsed: true
                    )
                    .contextMenu {
                        if let selectedCharacter = character {
                            if selectedCharacter.knownSpells.contains(spell) {
                                Button("Забыть", action: { [weak spell] in unknow(spell: spell) })
                            } else {
                                Button("Выучить", action: { [weak spell] in know(spell: spell) })
                            }
                            
                            if selectedCharacter.preparedSpells.contains(spell) {
                                Button("Отложить", action: { [weak spell] in unpare(spell: spell) })
                            } else {
                                Button("Подготовить", action: { [weak spell] in prepare(spell: spell) })
                            }

                            Divider()
                        }
                        
                        if spell.isHidden {
                            Button("Открыть", action: { [weak spell] in unhide(spell: spell) })
                        } else {
                            Button("Спрятать", action: { [weak spell] in hide(spell: spell) })
                        }
                        
                        Button("Править", action: { [weak spell] in edit(spell: spell) })
                    }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.systemGroupedTableContent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical, 2)
            }
        }
//        .sheet(item: $editingSpell) { spell in
//            SpellEditView(spell: spell)
//        }
    }

    func prepare(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }

        if !selectedCharacter.knownSpells.contains(spell) {
            selectedCharacter.knownSpells.append(spell)
        }
        
        if !selectedCharacter.preparedSpells.contains(spell) {
            selectedCharacter.preparedSpells.append(spell)
        }

        try? modelContext.save()
        CharacterUpdateService.send()
    }
    
    func unpare(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }
        
        
        if let index = selectedCharacter.preparedSpells.firstIndex(of: spell) {
            selectedCharacter.preparedSpells.remove(at: index)
        }

        try? modelContext.save()
        CharacterUpdateService.send()
    }

    func know(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }

        if !selectedCharacter.knownSpells.contains(spell) {
            selectedCharacter.knownSpells.append(spell)
        }

        try? modelContext.save()
        CharacterUpdateService.send()
    }
    
    func unknow(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }

        if let index = selectedCharacter.knownSpells.firstIndex(of: spell) {
            selectedCharacter.knownSpells.remove(at: index)
        }

        if let index = selectedCharacter.preparedSpells.firstIndex(of: spell) {
            selectedCharacter.preparedSpells.remove(at: index)
        }

        try? modelContext.save()
        CharacterUpdateService.send()
    }
    
    func edit(spell: Spell?) {
        guard let spell else {
            return
        }

        
    }
    
    func hide(spell: Spell?) {
        guard let spell,
              !spell.isHidden else {
            return
        }
        spell.isHidden = true
        try? modelContext.save()
    }
    
    func unhide(spell: Spell?) {
        guard let spell,
              spell.isHidden else {
            return
        }
        spell.isHidden = false
        try? modelContext.save()
    }
}
