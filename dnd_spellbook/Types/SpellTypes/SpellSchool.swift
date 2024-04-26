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
        case .divinition: "Разделения"
        case .illusion: "Иллюзий"
        case .transmutation: "Преобразования"
        case .enchantment: "Очарования"
        case .evocation: "Проявления"
        case .necromancy: "Некромантии"
        case .abjuration: "Ограждения"
        case .conjuration: "Призыва"
        }
    }
}
