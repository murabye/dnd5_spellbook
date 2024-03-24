//
//  Distantion.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.02.2024.
//

import Foundation
import SwiftData

@Model
class DistantionModel {
    
    @Relationship(deleteRule: .cascade, inverse: \Spell.distantionModel) var spells: [Spell]
    let onlyYou: Bool
    let touches: Bool
    let visibility: Bool
    let full: Bool
    let feet: Int
    
    init(from distantion: Distantion) {
        switch distantion {
        case .onlyYou:
            self.onlyYou = true
            self.touches = false
            self.visibility = false
            self.full = false
            self.feet = 0
            spells = []
        case .touches:
            self.onlyYou = false
            self.touches = true
            self.visibility = false
            self.full = false
            self.feet = 0
            spells = []
        case .visibility:
            self.onlyYou = false
            self.touches = false
            self.visibility = true
            self.full = false
            self.feet = 0
            spells = []
        case .full:
            self.onlyYou = false
            self.touches = false
            self.visibility = false
            self.full = true
            self.feet = 0
            spells = []
        case .feet(let int):
            self.onlyYou = false
            self.touches = false
            self.visibility = false
            self.full = false
            self.feet = int
            spells = []
        }
    }
    
    var unwrap: Distantion {
        if onlyYou {
            .onlyYou
        } else if touches {
            .touches
        } else if visibility {
            .visibility
        } else if full {
            .full
        } else {
            .feet(feet)
        }
    }
}

