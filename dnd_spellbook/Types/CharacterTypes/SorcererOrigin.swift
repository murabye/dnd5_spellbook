//
//  SorcererOrigin.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum SorcererOrigin: Int, CaseIterable, HaveName, Archetype, Codable {
    case legacyOfDragonsBlood
    case wildMagic
    case divineSoul
    case shadowMagic
    case stormWitchcraft
    case aberrantMind
    case clockworkSoul
    case moonWitch
    
    static var description = "Происхождение"

    static var defaultValue: Self {
        .wildMagic
    }
    
    var name: String {
        switch self {
        case .legacyOfDragonsBlood: "Наследие драконьей крови"
        case .wildMagic: "Дикая магия"
        case .divineSoul: "Божественная душа"
        case .shadowMagic: "Теневая магия"
        case .stormWitchcraft: "Штормовое колдовство"
        case .aberrantMind: "Аберрантный разум"
        case .clockworkSoul: "Заводная душа"
        case .moonWitch: "Лунное чародейство"
        }
    }
}
