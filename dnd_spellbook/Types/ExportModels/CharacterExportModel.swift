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
    let level: Int
    let name: String
    let knownSpells: [String]
    let preparedSpells: [String]
    let customKnownSpells: [CustomSpellExportModel]
    let customPreparedSpells: [CustomSpellExportModel]
    
    init(from: CharacterModel, allTags: [Tag]) {
        if let url = from.imageUrl,
           let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            self.image = image.pngData()
        } else {
            self.image = nil
        }
        self.level = from.level
        self.characterClass = from.characterClass
        self.name = from.name
        self.knownSpells = from.knownSpells
            .filter { !$0.isCustom }
            .map { $0.id }
        self.preparedSpells = from.preparedSpells
            .filter { !$0.isCustom }
            .map { $0.id }
        self.customKnownSpells = from.knownSpells
            .filter { $0.isCustom }
            .map { CustomSpellExportModel(spell: $0, allTags: allTags) }
        self.customPreparedSpells = from.preparedSpells
            .filter { $0.isCustom }
            .map { CustomSpellExportModel(spell: $0, allTags: allTags) }
    }
}
