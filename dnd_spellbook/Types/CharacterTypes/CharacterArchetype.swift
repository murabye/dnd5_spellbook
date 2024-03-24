//
//  CharacterArchetype.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

enum CharacterArchetype {
    
    case bard(BardCollegy)
    case wizard(WizardSchool)
    case druid(DruidCircle)
    case cleric(ClericDomain)
    case artificer(ArtificerSpeciality)
    case warlock(WarlockPatron)
    case paladin(PaladinOath)
    case ranger(RangerArchetype)
    case sorcerer(SorcererOrigin)
    case nothing
    
    var mainClass: CharacterClass {
        switch self {
        case .bard: .bard
        case .wizard: .wizard
        case .druid: .druid
        case .cleric: .cleric
        case .artificer: .artificer
        case .warlock: .warlock
        case .paladin: .paladin
        case .ranger: .ranger
        case .sorcerer: .sorcerer
        case .nothing: .nothing
        }
    }
        
    var subclassDesctiption: String {
        mainClass.subclassDesctiption
    }
}

extension CharacterArchetype: HaveName {
    
    var name: String {
        mainClass.name
    }
}

extension CharacterArchetype: Equatable {}

extension CharacterArchetype: Hashable {}

extension CharacterArchetype: Codable {}
