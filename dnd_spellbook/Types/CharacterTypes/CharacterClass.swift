//
//  CharacterClass.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum CharacterClass: Int, Codable, FilterFormSelectable, CaseIterable, Hashable {
    
    case bard
    case wizard
    case druid
    case cleric
    case artificer
    case warlock
    case paladin
    case ranger
    case sorcerer
    case nothing
}

extension CharacterClass: HaveName {

    var name: String {
        switch self {
        case .bard: "Бард"
        case .wizard: "Волшебник"
        case .druid: "Друид"
        case .cleric: "Жрец"
        case .artificer: "Изобретатель"
        case .warlock: "Колдун"
        case .paladin: "Паладин"
        case .ranger: "Следопыт"
        case .sorcerer: "Чародей"
        case .nothing: "Нет класса"
        }
    }
}

extension CharacterClass: Comparable {
    
    static func < (lhs: CharacterClass, rhs: CharacterClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension [ CharacterClass ] {
    var name: String {
        Array(self)
            .map(\.name)
            .sorted()
            .joined(separator: ", ")
    }
}
