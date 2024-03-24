//
//  WarlockPatron.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum WarlockPatron: Int, CaseIterable, Archetype, Codable {
    case archiFairy
    case disappearance
    case greatAncient
    case immortal
    case witchBlade
    case celestial
    case bottomless
    case genius
    case undead
    
    static var description = "Патрон"

    static var defaultValue: Self {
        .disappearance
    }

    var name: String {
        switch self {
        case .archiFairy: "Архифея"
        case .disappearance: "Исчадие"
        case .greatAncient: "Великий древний"
        case .immortal: "Бессмертный"
        case .witchBlade: "Ведьмовской клинок"
        case .celestial: "Небожитель"
        case .bottomless: "Бездонный"
        case .genius: "Гений"
        case .undead: "Нежить"
        }
    }
}
