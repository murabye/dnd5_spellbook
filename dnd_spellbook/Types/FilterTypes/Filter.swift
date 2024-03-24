//
//  Filter.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation
import SwiftData

@Model
class Filter: Hashable, Identifiable {

    var id: String { name }
    
    let name: String
    let levels: [Int]
    let noMaterials: Bool
    let maxMaterialPriceInGold: Int?
    let sources: [Sources]
    let schools: [SpellSchool]
    let actions: [NoConreteActionType]
    let concentration: Bool?
    @Relationship(deleteRule: .nullify) let included: [Tag]
    @Relationship(deleteRule: .nullify) let excluded: [Tag]
    let classes: [CharacterClass]
    let onlyMute: Bool
    let onlyNoHands: Bool
    
    init(
        name: String,
        levels: [Int],
        noMaterials: Bool,
        maxMaterialPriceInGold: Int? = nil,
        sources: [Sources],
        schools: [SpellSchool],
        actions: [NoConreteActionType],
        concentration: Bool? = nil,
        included: [Tag], 
        excluded: [Tag],
        classes: [CharacterClass],
        onlyMute: Bool,
        onlyNoHands: Bool
    ) {
        self.name = name
        self.levels = levels
        self.noMaterials = noMaterials
        self.maxMaterialPriceInGold = maxMaterialPriceInGold
        self.sources = sources
        self.schools = schools
        self.actions = actions
        self.concentration = concentration
        self.included = included
        self.excluded = excluded
        self.classes = classes
        self.onlyMute = onlyMute
        self.onlyNoHands = onlyNoHands
    }
}

extension Filter {
    
    func isSatisfy(spell: Spell, allMaterials: [Material], allTags: [Tag]) -> Bool {
        guard levels.isEmpty || levels.contains(spell.level) else { return false }
        guard !noMaterials || !spell.haveMaterials else { return false }
        
        if let maxMaterialPriceInGold,
           spell.materialPrice(allMaterials: allMaterials) > maxMaterialPriceInGold {
            return false
        }
        
        guard schools.isEmpty || schools.contains(spell.school) else { return false }
        guard actions.isEmpty || actions.contains(spell.typeOfActionNonConcrete) else { return false }
        if !sources.isEmpty {
            let filterSources = Set(sources)
            let spellSources = Set(spell.sources)
            if filterSources.intersection(spellSources).isEmpty {
                return false
            }
        }

        if let concentration,
           spell.concentration != concentration {
            return false
        }
        
        let includedSet = Set(included)
        let excludedSet = Set(excluded)
        let classesSet = Set(classes)
        let spellTags = spell.tags(allTags: allTags)

        guard includedSet.isEmpty || !includedSet.isDisjoint(with: spellTags) else { return false }
        guard excludedSet.isEmpty || excludedSet.isDisjoint(with: spellTags) else { return false }
        guard classesSet.isEmpty || !classesSet.isDisjoint(with: spell.classes) else { return false }

        guard !onlyMute || !spell.components.contains(.verbal) else { return false }
        guard !onlyNoHands || !spell.components.contains(.somatic) else { return false }

        return true
    }
}

extension Filter {
    
    func satisfying(spells: [Spell], allMaterials: [Material], allTags: [Tag]) -> [Spell] {
        spells.filter { isSatisfy(spell: $0, allMaterials: allMaterials, allTags: allTags) }
    }
}


extension Spell {
    var haveMaterials: Bool {
        for component in self.components {
            switch component {
            case .material: return true
            default: continue
            }
        }
        
        return false
    }
    
    func materialPrice(allMaterials: [Material]) -> Int {
        var price: Int = 0
        
        for component in self.components {
            switch component {
            case let .material(materialId):
                guard let material = allMaterials.first(where: { $0.id == materialId }) else {
                    continue
                }
                price += material.cost
            default: continue
            }
        }
        
        return price
    }
}
