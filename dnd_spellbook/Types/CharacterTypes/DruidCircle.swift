//
//  DruidCircle.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum DruidCircle: Int, CaseIterable, Archetype, Codable {
    case land
    case moon
    case shepherd
    case dreams
    case wilfFire
    case stars
    case spores
    
    static var description = "Круг"

    static var defaultValue: Self {
        .moon
    }

    var name: String {
        switch self {
        case .land: "Круг земли"
        case .moon: "Круг луны"
        case .shepherd: "Круг пастыря"
        case .dreams: "Круг снов"
        case .wilfFire: "Круг дикого огня"
        case .stars: "Круг звёзд"
        case .spores: "Круг спор"
        }
    }
}
