//
//  SetuppedSpellView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 29.05.2024.
//

import SwiftData
import SwiftUI

struct SetuppedSpellView: View {
    @State var spell: Spell
    @State var editingSpell: Spell?
    @Environment(\.modelContext) var modelContext
    @Binding var character: CharacterModel?

    @Binding var preparedSpellsMap: [UInt: Bool]
    @Binding var knownSpellsMap: [UInt: Bool]
    @Binding var lockedSpellsMap: [UInt: Bool]
    
    private var isSpellLocked: Bool {
        lockedSpellsMap[spell.id] ?? false
    }
    
    var canEdit: Bool = true
    let name: SectionsName
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
            isLockedRelationship: isSpellLocked,
            collapsed: true
        )
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            switch name {
            case .prepared:
                if character != nil, !isSpellLocked {
                    Button("Отложить", action: { [weak spell] in unprepare(spell: spell) })
                    Button("Забыть", action: { [weak spell] in unknow(spell: spell) })
                    Button("Закрепить", action: { [weak spell] in lock(spell: spell) })
                    Divider()
                } else if isSpellLocked {
                    Button("Открепить", action: { [weak spell] in unlock(spell: spell) })
                }
            case .known:
                if character != nil, !isSpellLocked {
                    Button("Подготовить", action: { [weak spell] in prepare(spell: spell) })
                    Button("Забыть", action: { [weak spell] in unknow(spell: spell) })
                    Button("Закрепить", action: { [weak spell] in lock(spell: spell) })
                    Divider()
                } else if isSpellLocked {
                    Button("Открепить", action: { [weak spell] in unlock(spell: spell) })
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
                    if preparedSpellsMap[spell.id] != true {
                        Button("Подготовить", action: { [weak spell] in prepare(spell: spell) })
                    } else if !isSpellLocked {
                        Button("Отложить", action: { [weak spell] in unprepare(spell: spell) })
                        Button("Закрепить", action: { [weak spell] in lock(spell: spell) })
                    } else {
                        Button("Открепить", action: { [weak spell] in unlock(spell: spell) })
                    }
                    
                    if knownSpellsMap[spell.id] != true {
                        Button("Выучить", action: { [weak spell] in know(spell: spell) })
                    } else if !isSpellLocked {
                        Button("Забыть", action: { [weak spell] in unknow(spell: spell) })
                        Button("Закрепить", action: { [weak spell] in lock(spell: spell) })
                    } else {
                        Button("Открепить", action: { [weak spell] in unlock(spell: spell) })
                    }
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
        let spellId = spell.id
        let selectedCharacterId = selectedCharacter.id

        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(predicate: #Predicate { rel in
            rel.spellId == spellId && rel.characterId == selectedCharacterId
        })
        fetchDescriptor.fetchLimit = 1

        if let relation = (try? modelContext.fetch(fetchDescriptor))?.first,
           !relation.isLocked {
            relation.typeOfRelation = .prepared
            try? modelContext.save()
            onPrepare(spell)
            onUnknow(spell)
        } else {
            let relation = CharacterToSpell(
                characterId: selectedCharacter.id,
                spellId: spell.id,
                spellLevel: spell.level,
                isLocked: false,
                isSpellCustom: spell.isCustom,
                typeOfRelation: .known,
                spell: spell
            )
            modelContext.insert(relation)
            try? modelContext.save()
            onPrepare(spell)
        }
    }
    
    func unprepare(spell: Spell?) {
        guard let spellId = spell?.id,
              let spell,
              let selectedCharacterId = character?.id else {
            return
        }
        
        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(predicate: #Predicate { rel in
            rel.spellId == spellId && rel.characterId == selectedCharacterId
        })
        fetchDescriptor.fetchLimit = 1
        
        if let relation = (try? modelContext.fetch(fetchDescriptor))?.first,
           !relation.isLocked {
            relation.typeOfRelation = .known
            try? modelContext.save()
            onUnprepare(spell)
            onKnow(spell)
        }
    }

    func know(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }
        let spellId = spell.id
        let selectedCharacterId = selectedCharacter.id
        
        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(predicate: #Predicate { rel in
            rel.spellId == spellId && rel.characterId == selectedCharacterId
        })
        fetchDescriptor.fetchLimit = 1

        if ((try? modelContext.fetchCount(fetchDescriptor)) ?? 0) == 0 {
            let relation = CharacterToSpell(
                characterId: selectedCharacter.id,
                spellId: spell.id,
                spellLevel: spell.level,
                isLocked: false, 
                isSpellCustom: spell.isCustom,
                typeOfRelation: .known,
                spell: spell
            )
            modelContext.insert(relation)
            try? modelContext.save()
            onKnow(spell)
        }
    }
    
    func unknow(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character else {
            return
        }
        let spellId = spell.id
        let selectedCharacterId = selectedCharacter.id

        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(predicate: #Predicate { rel in
            rel.spellId == spellId && rel.characterId == selectedCharacterId
        })
        fetchDescriptor.fetchLimit = 1
        
        if let relation = (try? modelContext.fetch(fetchDescriptor))?.first,
           !relation.isLocked {
            modelContext.delete(relation)
            try? modelContext.save()
            onUnknow(spell)
        }
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
    
    func lock(spell: Spell?) {
        guard let spell, 
            let selectedCharacter = character,
            !isSpellLocked else {
                return
        }
        
        lockedSpellsMap[spell.id] = true
        let spellId = spell.id
        let selectedCharacterId = selectedCharacter.id

        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(predicate: #Predicate { rel in
            rel.spellId == spellId && rel.characterId == selectedCharacterId
        })
        fetchDescriptor.fetchLimit = 1
        
        if let relation = (try? modelContext.fetch(fetchDescriptor))?.first {
            relation.isLocked = true
            try? modelContext.save()
        }
    }
    
    func unlock(spell: Spell?) {
        guard let spell,
              let selectedCharacter = character,
                isSpellLocked else {
            return
        }
        
        lockedSpellsMap[spell.id] = false
        let spellId = spell.id
        let selectedCharacterId = selectedCharacter.id

        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(predicate: #Predicate { rel in
            rel.spellId == spellId && rel.characterId == selectedCharacterId
        })
        fetchDescriptor.fetchLimit = 1
        
        if let relation = (try? modelContext.fetch(fetchDescriptor))?.first {
            relation.isLocked = false
            try? modelContext.save()
        }
    }
}
