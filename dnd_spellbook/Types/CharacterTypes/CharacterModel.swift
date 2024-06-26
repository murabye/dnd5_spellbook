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
    let tagActions: [Int: TagAction]
    @Relationship(deleteRule: .nullify) var knownSpells: [Spell]
    @Relationship(deleteRule: .nullify) var preparedSpells: [Spell]

    init(
        id: String,
        imageUrl: URL?,
        characterClass: CharacterClass?,
        name: String,
        tagActions: [Int: TagAction],
        knownSpells: [Spell],
        preparedSpells: [Spell]
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.characterClass = characterClass
        self.name = name
        self.tagActions = tagActions
        self.knownSpells = knownSpells
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
        && lhs.tagActions == rhs.tagActions
        && lhs.knownSpells == rhs.knownSpells
        && lhs.preparedSpells == rhs.preparedSpells
    }
}
