//
//  CharacterExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation
import UIKit

class CharacterExportModel: Codable {
    
    let image: Data?
    let characterClass: CharacterClass?
    let levels: LevelList
    let usedLevels: LevelList
    let name: String
    let relationships: [CharacterToSpellExportModel]
    let customSpellsRelationships: [CustomSpellExportModel]
    
    init(
        from: CharacterModel,
        allTags: [Tag],
        allCustomSpells: [Spell],
        characterRelationships: [CharacterToSpell]
    ) {
        if let url = from.imageUrl,
           let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            self.image = image.pngData()
        } else {
            self.image = nil
        }
        self.levels = from.levels
        self.usedLevels = from.usedLevels
        self.characterClass = from.characterClass
        self.name = from.name
        
        self.relationships = characterRelationships
            .filter { !$0.isSpellCustom }
            .map { relationship in
                CharacterToSpellExportModel(
                    spellId: relationship.spellId,
                    isLocked: relationship.isLocked,
                    typeOfRelation: relationship.typeOfRelation
                )
            }
        
        self.customSpellsRelationships =  characterRelationships
            .filter { $0.isSpellCustom }
            .compactMap { relationship in
                guard let spell = allCustomSpells.first(where: { $0.id == relationship.spellId }) else { return nil }
                return CustomSpellExportModel(
                    spell: spell,
                    allTags: allTags,
                    isLockedRelationship: relationship.isLocked,
                    relationType: relationship.typeOfRelation
                )
            }
    }
}
