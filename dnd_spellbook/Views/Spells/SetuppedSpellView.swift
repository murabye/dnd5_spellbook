//
//  SetuppedSpellView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 29.05.2024.
//

// TODO: VARVAR https://habr.com/ru/articles/784768/

import SwiftData
import SwiftUI

struct SetuppedSpellView: View {
    @Binding var spell: Spell
    @State var editingSpell: Spell?
    @Environment(\.modelContext) var modelContext
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
        SpellView(
            spell: spell,
            collapsed: true
        )
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            switch name {
            case .prepared:
                if character != nil {
                    Button("Отложить", action: { [weak spell] in unprepare(spell: spell) })
                    Button("Забыть", action: { [weak spell] in unknow(spell: spell) })
                    Divider()
                }
            case .known:
                if character != nil {
                    Button("Подготовить", action: { [weak spell] in prepare(spell: spell) })
                    Button("Забыть", action: { [weak spell] in unknow(spell: spell) })
                    Divider()
                }
            case .other:
                if character != nil {
                    Button("Подготовить", action: { [weak spell] in prepare(spell: spell) })
                    Button("Выучить", action: { [weak spell] in know(spell: spell) })
                    Divider()
                }
                Button("Спрятать", action: { [weak spell] in hide(spell: spell) })
            case .hidden:
                if character != nil {
                    Button("Подготовить", action: { [weak spell] in prepare(spell: spell) })
                    Button("Выучить", action: { [weak spell] in know(spell: spell) })
                    Divider()
                }
                Button("Открыть", action: { [weak spell] in unhide(spell: spell) })
            case .search:
                if character != nil {
                    Text("Для оптимизации пока не проверяем состояние заклинания")
                    Button("Подготовить...", action: { [weak spell] in prepare(spell: spell) })
                    Button("Выучить...", action: { [weak spell] in know(spell: spell) })
                    Button("Отложить...", action: { [weak spell] in unprepare(spell: spell) })
                    Button("Забыть...", action: { [weak spell] in unknow(spell: spell) })
                    Divider()
                }
                if spell.isHidden {
                    Button("Открыть", action: { [weak spell] in unhide(spell: spell) })
                } else {
                    Button("Спрятать", action: { [weak spell] in hide(spell: spell) })
                }
            }
            
            if canEdit {
                Button("Править", action: { [weak spell] in self.editingSpell = spell })
            }
            if spell.isCustom {
                Button("Удалить", role: .destructive) { [weak spell] in remove(spell: spell) }
            }
        }
        .padding(.vertical, 2)
        .sheet(item: $editingSpell) { spell in
            SpellEditView(spell: spell)
        }
    }

    func prepare(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }

        if let index = selectedCharacter.knownSpells.firstIndex(of: spell) {
            selectedCharacter.knownSpells.remove(at: index)
            onUnknow(spell)
        }
        
        if !selectedCharacter.preparedSpells.contains(spell) {
            selectedCharacter.preparedSpells.append(spell)
            spell.isHidden = false
            onPrepare(spell)
        }
        
        try? modelContext.save()
        CharacterUpdateService.send()
    }
    
    func unprepare(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }
        
        if let index = selectedCharacter.preparedSpells.firstIndex(of: spell) {
            selectedCharacter.preparedSpells.remove(at: index)
            onUnprepare(spell)
            selectedCharacter.knownSpells.append(spell)
            onKnow(spell)
            try? modelContext.save()
            CharacterUpdateService.send()
        }
    }

    func know(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }

        if !selectedCharacter.knownSpells.contains(spell) {
            selectedCharacter.knownSpells.append(spell)
            spell.isHidden = false
            onKnow(spell)
            try? modelContext.save()
            CharacterUpdateService.send()
        }
    }
    
    func unknow(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }

        if let index = selectedCharacter.knownSpells.firstIndex(of: spell) {
            selectedCharacter.knownSpells.remove(at: index)
            onUnknow(spell)
        }

        if let index = selectedCharacter.preparedSpells.firstIndex(of: spell) {
            selectedCharacter.preparedSpells.remove(at: index)
            onUnprepare(spell)
        }

        try? modelContext.save()
        CharacterUpdateService.send()
    }
        
    func hide(spell: Spell?) {
        guard let spell,
              !spell.isHidden else {
            return
        }
        spell.isHidden = true
        onHide(spell)
        try? modelContext.save()
    }
    
    func unhide(spell: Spell?) {
        guard let spell,
              spell.isHidden else {
            return
        }
        spell.isHidden = false
        onUnhide(spell)
        try? modelContext.save()
    }
    
    func remove(spell: Spell?) {
        guard let spell,
              spell.isCustom else {
            return
        }
        onRemove(spell)
        modelContext.delete(spell)
        try? modelContext.save()
    }
}
