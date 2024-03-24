//
//  SpellSchool.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation

enum SpellSchool: Int, FilterFormSelectable, CaseIterable, Equatable, Codable {
    
    case divinition
    case illusion
    case transmutation
    case enchantment
    case evocation
    case necromancy
    case abjuration
    case conjuration
}

extension SpellSchool: HaveName {
    
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
        }
    }
}
