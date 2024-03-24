//
//  BardCollegy.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum BardCollegy: Int, CaseIterable, Archetype, Codable {
    case valor
    case knowledge
    case swords
    case charm
    case whispers
    case eloratory
    case creation
    case spirits
    
    static var defaultValue: Self {
        .charm
    }
    
    static var description = "Коллегия"
    
    var name: String {
        switch self {
        case .valor: "Коллегия Доблести"
        case .knowledge: "Коллегия Знаний"
        case .swords: "Коллегия Мечей"
        case .charm: "Коллегия Очарования"
        case .whispers: "Коллегия Шёпотов"
        case .eloratory: "Коллегия Красноречия"
        case .creation: "Коллегия Созидания"
        case .spirits: "Коллегия Духов"
        }
    }
}
