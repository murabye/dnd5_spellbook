//
//  PaladinOath.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum PaladinOath: Int, CaseIterable, Archetype, Codable {
    case devotion
    case ancients
    case revenge
    case oathbreaker
    case crown
    case redemption
    case subjugation
    case glory
    case wardens
    
    static var description = "Клятва"

    static var defaultValue: Self {
        .devotion
    }

    var name: String {
        switch self {
        case .devotion: "Клятва преданности"
        case .ancients: "Клятва древних"
        case .revenge: "Клятва мести"
        case .oathbreaker: "Клятвопреступник"
        case .crown: "Клятва короны"
        case .redemption: "Клятва искупления"
        case .subjugation: "Клятва покорения"
        case .glory: "Клятва славы"
        case .wardens: "Клятва смотрителей"
        }
    }
}
