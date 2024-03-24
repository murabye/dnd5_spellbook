//
//  Sources.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation

enum Sources: Int, FilterFormSelectable, Equatable, CaseIterable, Codable {

    case playerHandbook
    case sproutingChaos
    case swordCoastAdventurersGuide
    case xanatarsGuide
    case tashasCauldron
    case tashasOptionalCauldron
    case princesOfTheApocalypse
    case explorersGuideToWildeount
    case guildmasterGuideToRavnica
}

extension Sources: HaveName {

    var name: String {
        switch self {
        case .playerHandbook:
            "Книга игрока"
        case .sproutingChaos:
            "Прорастающий Хаос"
        case .swordCoastAdventurersGuide:
            "Путеводитель Приключенца по Побережью Мечей"
        case .xanatarsGuide:
            "Руководство Занатара обо всем"
        case .tashasCauldron:
            "Котёл Таши со всякой всячиной"
        case .tashasOptionalCauldron:
            "Опциональное из Котла Таши со всякой всячиной"
        case .princesOfTheApocalypse:
            "Princes of the Apocalypse"
        case .explorersGuideToWildeount:
            "Explorer's Guide to Wildeount"
        case .guildmasterGuideToRavnica:
            "Guildmaster's Guide to Ravnica"
        }
    }
}
