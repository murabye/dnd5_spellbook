//
//  Character.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation
import SwiftData

@Model
class CharacterModel {

    let id: String
    let imageUrl: URL?
    let characterClass: CharacterClass?
    let name: String
    let levels: LevelList
    var usedLevels: LevelList
    @Relationship(deleteRule: .nullify) var knownSpells: [Spell]
    @Relationship(deleteRule: .nullify) var preparedSpells: [Spell]

    init(
        id: String,
        imageUrl: URL?,
        characterClass: CharacterClass?,
        name: String,
        levels: LevelList,
        usedLevels: LevelList,
        knownSpells: [Spell],
        preparedSpells: [Spell]
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.characterClass = characterClass
        self.name = name
        self.levels = levels
        self.knownSpells = []
        self.preparedSpells = []
        self.usedLevels = usedLevels
        
        set(knownSpells: knownSpells)
        set(preparedSpells: preparedSpells)
    }
    
    func set(knownSpells: [Spell]) {
        self.knownSpells = knownSpells
    }
    
    func set(preparedSpells: [Spell]) {
        self.preparedSpells = preparedSpells
    }
}

extension CharacterModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CharacterModel: Identifiable {
    
    static func == (lhs: CharacterModel, rhs: CharacterModel) -> Bool {
        lhs.imageUrl == rhs.imageUrl
        && lhs.id == rhs.id
        && lhs.characterClass == rhs.characterClass
        && lhs.name == rhs.name
        && lhs.knownSpells == rhs.knownSpells
        && lhs.preparedSpells == rhs.preparedSpells
        && lhs.levels == rhs.levels
    }
}
