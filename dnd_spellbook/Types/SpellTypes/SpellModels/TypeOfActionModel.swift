//
//  TypeOfAction.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.02.2024.
//

import Foundation
import SwiftData

@Model
class TypeOfActionModel {
    
    @Relationship(deleteRule: .cascade, inverse: \Spell.typeOfActionModel) var spells: [Spell]
    let action: Bool
    let bonus: Bool
    let reaction: Bool
    let time: Int
    
    init(from typeOfAction: TypeOfAction) {
        switch typeOfAction {
        case .action:
            self.action = true
            self.bonus = false
            self.reaction = false
            self.time = 0
            spells = []
        case .bonus:
            self.action = false
            self.bonus = true
            self.reaction = false
            self.time = 0
            spells = []
        case .reaction:
            self.action = false
            self.bonus = false
            self.reaction = true
            self.time = 0
            spells = []
        case .time(let int):
            self.action = false
            self.bonus = false
            self.reaction = false
            self.time = int
            spells = []
        }
    }
    
    var unwrap: TypeOfAction {
        if action {
            .action
        } else if bonus {
            .bonus
        } else if reaction {
            .reaction
        } else {
            .time(minutes: time)
        }
    }
}
