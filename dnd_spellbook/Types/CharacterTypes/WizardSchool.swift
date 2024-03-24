//
//  WizardSchool.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum WizardSchool: Int, CaseIterable, Archetype, Codable {
    case divinition
    case illusion
    case transmutation
    case enchantment
    case evocation
    case necromancy
    case abjuration
    case conjuration
    case warMagic
    case chronurgyMagic
    case graviturgyMagic
    case orderOfScribes
    case songOfBlade
    
    static var description = "Школа"

    static var defaultValue: Self {
        .evocation
    }

    var name: String {
        switch self {
        case .divinition: "Школа разделения"
        case .illusion: "Школа иллюзий"
        case .transmutation: "Школа преобразования"
        case .enchantment: "Школа очарования"
        case .evocation: "Школа проявления"
        case .necromancy: "Школа некромантии"
        case .abjuration: "Школа ограждения"
        case .conjuration: "Школа призыва"
        case .warMagic: "Военная магия"
        case .chronurgyMagic: "Магия хронургии"
        case .graviturgyMagic: "Магия гравитургии"
        case .orderOfScribes: "Орден писцов"
        case .songOfBlade: "Песнь клинка"
        }
    }
}
