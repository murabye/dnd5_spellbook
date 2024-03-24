//
//  ClericDomain.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum ClericDomain: Int, CaseIterable, Archetype, Codable {
    case storm
    case war
    case life
    case knowledge
    case deception
    case nature
    case light
    case death
    case magic
    case forge
    case rest
    case peace
    case order
    case twilight
    
    static var description = "Домен"

    static var defaultValue: Self {
        .life
    }
    
    var name: String {
        switch self {
        case .storm: "Домен бури"
        case .war: "Домен войны"
        case .life: "Домен жизни"
        case .knowledge: "Домен знаний"
        case .deception: "Домен обмана"
        case .nature: "Домен природы"
        case .light: "Домен света"
        case .death: "Домен смерти"
        case .magic: "Домен магии"
        case .forge: "Домен кузни"
        case .rest: "Домен упокоения"
        case .peace: "Домен мира"
        case .order: "Домен порядка"
        case .twilight: "Домен сумерек"
        }
    }
}
