//
//  ArtificerSpeciality.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum ArtificerSpeciality: Int, CaseIterable, Archetype, Codable {
    case alchemist
    case artillerist
    case smith
    case armor
    
    static var description = "Специальность"

    static var defaultValue: Self {
        .alchemist
    }
    
    var name: String {
        switch self {
        case .alchemist: "Алхимик"
        case .artillerist: "Артиллерист"
        case .smith: "Боевой кузнец"
        case .armor: "Бронник"
        }
    }
}
