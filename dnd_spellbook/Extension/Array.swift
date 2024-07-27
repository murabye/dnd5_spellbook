//
//  Array.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 12.04.2024.
//

import Foundation

public extension Optional where Wrapped: Collection {

    var isEmptyOrNil: Bool {
        self?.isEmpty ?? true
    }
}

extension Array where Element: Equatable {
    func subtracting(_ array: Array<Element>) -> Array<Element> {
        self.filter { !array.contains($0) }
    }
}

extension Dictionary where Key == Int, Value == Array<Spell> {
    
    var biggerLevel: Int {
        for level in Array(0...9).reversed() {
            if let spellList = self[level], !spellList.isEmpty {
                return level
            }
        }
        return -1
    }

    mutating func appendOrSet(_ spell: Spell?) {
        guard let spell else { return }
        if self[spell.level] == nil {
            self[spell.level] = [spell]
        } else {
            self[spell.level]?.append(spell)
        }
    }
        
    mutating func appendOrSetIfNotLast(_ spell: Spell?) {
        guard let spell,
            biggerLevel >= spell.level else { return }
        
        if let lastElem = self[spell.level]?.last {
            let lastId = lastElem.id
            if lastId < spell.id { return }
            self[spell.level]?.insert(spell, at: 0)
        } else {
            self[spell.level] = [spell]
        }
    }
}
