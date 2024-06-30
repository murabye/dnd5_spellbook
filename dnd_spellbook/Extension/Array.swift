//
//  Array.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 12.04.2024.
//

import Foundation

extension Array where Element: Equatable {
    func subtracting(_ array: Array<Element>) -> Array<Element> {
        self.filter { !array.contains($0) }
    }
}

extension Dictionary where Key == Int, Value == Array<Spell> {
    
    mutating func appendOrSet(_ spell: Spell) {
        if self[spell.level] == nil {
            self[spell.level] = [spell]
        } else {
            self[spell.level]?.append(spell)
        }
    }
}
