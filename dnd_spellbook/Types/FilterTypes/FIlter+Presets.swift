//
//  FIlter+Presets.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.04.2024.
//

import Foundation

extension Filter {
    
    static var free = Filter(
        name: "Бесплатные",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: 0,
        sources: Sources.allCases,
        schools: SpellSchool.allCases,
        actions: NoConreteActionType.allCases,
        concentration: nil,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: false,
        onlyNoHands: false,
        character: nil
    )
    
    static var phb = Filter(
        name: "PHB",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: nil,
        sources: [.playerHandbook],
        schools: SpellSchool.allCases,
        actions: NoConreteActionType.allCases,
        concentration: nil,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: false,
        onlyNoHands: false,
        character: nil
    )
    
    static var bonus = Filter(
        name: "Бонусное",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: nil,
        sources: Sources.allCases,
        schools: SpellSchool.allCases,
        actions: [.bonus],
        concentration: nil,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: false,
        onlyNoHands: false,
        character: nil
    )
    
    static var mainAction = Filter(
        name: "Основное",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: nil,
        sources: Sources.allCases,
        schools: SpellSchool.allCases,
        actions: [.action],
        concentration: nil,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: false,
        onlyNoHands: false,
        character: nil
    )

    static var noConcentration = Filter(
        name: "Без концентрации",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: nil,
        sources: Sources.allCases,
        schools: SpellSchool.allCases,
        actions: NoConreteActionType.allCases,
        concentration: false,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: false,
        onlyNoHands: false,
        character: nil
    )

    static var noSound = Filter(
        name: "Немота",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: nil,
        sources: Sources.allCases,
        schools: SpellSchool.allCases,
        actions: NoConreteActionType.allCases,
        concentration: nil,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: true,
        onlyNoHands: false,
        character: nil
    )
    
    static var noHand = Filter(
        name: "Заняты руки",
        levels: Array(0...9),
        noMaterials: false,
        maxMaterialPriceInGold: nil,
        sources: Sources.allCases,
        schools: SpellSchool.allCases,
        actions: NoConreteActionType.allCases,
        concentration: nil,
        included: [],
        excluded: [],
        classes: CharacterClass.allCases,
        onlyMute: false,
        onlyNoHands: true,
        character: nil
    )
    
    static func filterForClass(
        name: String,
        characterClass: CharacterClass,
        level: Int,
        copy: Int
    ) -> Filter {
        Filter(
            name: [name, characterClass.name, "\(level) круг", copy == 0 ? nil : "(\(copy))"]
                .compactMap { $0 }
                .joined(separator: " "),
            levels: Array(0...level),
            noMaterials: false,
            maxMaterialPriceInGold: nil,
            sources: Sources.allCases,
            schools: SpellSchool.allCases,
            actions: NoConreteActionType.allCases,
            concentration: nil,
            included: [],
            excluded: [],
            classes: [characterClass],
            onlyMute: false,
            onlyNoHands: false,
            character: nil
        )
    }
}
