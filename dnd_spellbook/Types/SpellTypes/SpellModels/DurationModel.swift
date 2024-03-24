//
//  Duration.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.02.2024.
//

import Foundation
import SwiftData

@Model
class DurationModel {
    
    @Relationship(deleteRule: .cascade, inverse: \Spell.durationModel) var spells: [Spell]
    let isInstantly: Bool
    let isRaundes: Bool
    let isTime: Bool
    let isClause: Bool
    let isMany: Bool
    let number: Int
    
    init(from duration: Duration) {
        switch duration {
        case .instantly:
            isInstantly = true
            isRaundes = false
            isTime = false
            isClause = false
            isMany = false
            number = 0
            spells = []
        case .raundes(let int):
            isInstantly = false
            isRaundes = true
            isTime = false
            isClause = false
            isMany = false
            number = int
            spells = []
        case .time(let minutes):
            isInstantly = false
            isRaundes = false
            isTime = true
            isClause = false
            isMany = false
            number = minutes
            spells = []
        case .clause:
            isInstantly = false
            isRaundes = false
            isTime = false
            isClause = true
            isMany = false
            number = 0
            spells = []
        case .many:
            isInstantly = true
            isRaundes = false
            isTime = false
            isClause = false
            isMany = true
            number = 0
            spells = []
        }
    }
    
    var unwrap: Duration {
        if isInstantly {
            .instantly
        } else if isRaundes {
            .raundes(number)
        } else if isTime {
            .time(minutes: number)
        } else if isClause {
            .clause
        } else {
            .many
        }
    }
}
