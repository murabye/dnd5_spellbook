//
//  SpellGeneratorView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.06.2024.
//

import Foundation

struct SpellViewGenerator {
    
    static func generateSpells(
        from spells: [Spell]
    ) -> [SpellListContentModel] {
        var result = [SpellListContentModel]()
        var level = -1
        
        for spell in spells {
            if spell.level != level {
                level = spell.level
                result.append(.init(type: .level(level)))
            }
            result.append(.init(type: .spell(spell)))
        }
        
        return result
    }
}
