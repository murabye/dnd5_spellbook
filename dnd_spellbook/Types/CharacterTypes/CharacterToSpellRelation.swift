//
//  CharacterToSpellRelation.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 15.07.2024.
//

import Foundation
import SwiftData

enum SpellRelationType: Int, Codable {
    
    case prepared = 0
    case known = 1
}

@Model
class CharacterToSpell {
    
    let characterId: String
    let spellId: UInt
    let spellLevel: Int
    var isLocked: Bool
    var isSpellCustom: Bool
    var typeOfRelation: SpellRelationType
    @Relationship(deleteRule: .nullify) var spell: Spell?

    init(
        characterId: String,
        spellId: UInt,
        spellLevel: Int,
        isLocked: Bool,
        isSpellCustom: Bool,
        typeOfRelation: SpellRelationType,
        spell: Spell?
    ) {
        self.characterId = characterId
        self.spellId = spellId
        self.spellLevel = spellLevel
        self.isLocked = isLocked
        self.isSpellCustom = isSpellCustom
        self.typeOfRelation = typeOfRelation
        self.spell = spell
    }
    
    static func lockedSpellMap(modelContext: ModelContext) -> [UInt: Bool] {
        guard let characterId = UserDefaults.standard.selectedId, !characterId.isEmpty else { return [:] }
        var fetchDescriptor = FetchDescriptor<CharacterToSpell>(
            predicate: #Predicate { relation in
                relation.characterId == characterId && relation.isLocked == true
            }
        )
        guard let allData = try? modelContext.fetch(fetchDescriptor) else { return [:] }
        var result: [UInt: Bool] = [:]
        allData.forEach { relation in
            result[relation.spellId] = true
        }
        return result
    }
}

class CharacterToSpellExportModel: Codable {
    
    let spellId: UInt
    let isLocked: Bool
    let typeOfRelation: SpellRelationType
    
    init(
        spellId: UInt,
        isLocked: Bool,
        typeOfRelation: SpellRelationType
    ) {
        self.spellId = spellId
        self.isLocked = isLocked
        self.typeOfRelation = typeOfRelation
    }
}
