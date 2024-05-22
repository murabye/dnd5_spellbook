//
//  SpellExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation

class CustomSpellExportModel: Codable {

    let id: String
    let name: String
    let engName: String?
    let labelling: String
    let concentration: Bool
    let level: Int
    let school: SpellSchool
    let sources: [Sources]
    let classes: [CharacterClass]
    let canUpcast: Bool
    let typeOfActionModel: TypeOfActionExportModel
    let distantionModel: DistantionExportModel
    let durationModel: DurationExportModel
    let initialTags: [String]
    let customTags: [CustomTagExportModel]
    let componentsModel: [ComponentsExportModel]
    
    init(spell: Spell, allTags: [Tag]) {
        self.id = spell.id
        self.engName = spell.engName
        self.name = spell.name
        self.labelling = spell.descrText
        self.concentration = spell.concentration
        self.level = spell.level
        self.school = spell.school
        self.sources = spell.sources
        self.classes = spell.classes
        self.canUpcast = spell.canUpcast
        self.typeOfActionModel = TypeOfActionExportModel(typeOfAction: spell.typeOfActionModel)
        self.distantionModel = DistantionExportModel(distantion: spell.distantionModel)
        self.durationModel = DurationExportModel(duration: spell.durationModel)
        let allTags = spell.tags(allTags: allTags)
        self.initialTags = allTags
            .filter { !$0.isCustom }
            .map { $0.id }
        self.customTags = allTags
            .filter(\.isCustom)
            .map { CustomTagExportModel(from: $0) }
        self.componentsModel = spell.componentsModel
            .map { ComponentsExportModel(components: $0) }
    }
}
