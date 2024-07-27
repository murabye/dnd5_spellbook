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

    init(
        id: String,
        imageUrl: URL?,
        characterClass: CharacterClass?,
        name: String,
        levels: LevelList,
        usedLevels: LevelList
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.characterClass = characterClass
        self.name = name
        self.levels = levels
        self.usedLevels = usedLevels
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
        && lhs.levels == rhs.levels
    }
}
