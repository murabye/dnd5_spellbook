//
//  ViewModels.swift
//  dnd_spellbook
//
//  Created by Vladimir Petrov on 29.05.24.
//

import Foundation

struct FilterModel: Hashable, Identifiable {
    
    enum FilterType: Hashable {
        case plus
        case reset
        case fiter(_ filter: Filter)
    }
    
    let id: String
    
    let type: FilterType
    
    init(_ type: FilterType) {
        self.type = type
        switch type {
        case .plus:
            self.id = "plus"
        case .reset:
            self.id = "reset"
        case .fiter(let filter):
            self.id = filter.id
        }
    }
}

struct SpellListContentModel: Hashable, Identifiable {
    
    enum SpellListContentType: Equatable, Hashable {

        case spell(Spell)
        case level(Int)
        case category(SectionsName)
        case load
    }
    
    let id: String
    let type: SpellListContentType

    init(type: SpellListContentType) {
        self.type = type
        switch type {
        case .spell(let spell):
            self.id = spell.id
        case .level(let int):
            self.id = "\(int)"
        case .category(let SectionsName):
            self.id = SectionsName.rawValue
        case .load:
            self.id = "load"
        }
    }
}
