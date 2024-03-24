//
//  RangerArchetype.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum RangerArchetype: Int, CaseIterable, Archetype, Codable {
    case hunter
    case lordOfTheBeasts
    case wandererOfTheHorizon
    case shadowhunter
    case monsterKiller
    case fairyWanderer
    case swarmGuardian
    case drakeRidder
    
    static var description = "Архетип"

    static var defaultValue: Self {
        .hunter
    }

    var name: String {
        switch self {
        case .hunter: "Охотник"
        case .lordOfTheBeasts: "Повелитель зверей"
        case .wandererOfTheHorizon: "Странник горизонта"
        case .shadowhunter: "Сумрачный охотник"
        case .monsterKiller: "Убийца монстров"
        case .fairyWanderer: "Странник фей"
        case .swarmGuardian: "Хранитель роя"
        case .drakeRidder: "Наездник на дрейке"
        }
    }
}
