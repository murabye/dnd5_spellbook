//
//  Duration.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.02.2024.
//

import Foundation
import SwiftData

@Model
class ComponentsModel {
    
    @Relationship(deleteRule: .noAction, inverse: \Spell.componentsModel) var spells: [Spell]
    let material: String
    let somatic: Bool
    let verbal: Bool
    let authorPay: Int
    
    init(from component: Component) {
        switch component {
        case .material(let id):
            self.material = id
            self.somatic = false
            self.verbal = false
            self.authorPay = 0
            spells = []
        case .somatic:
            self.material = ""
            self.somatic = true
            self.verbal = false
            self.authorPay = 0
            spells = []
        case .verbal:
            self.material = ""
            self.somatic = false
            self.verbal = true
            self.authorPay = 0
            spells = []
        case .authorPay(let int):
            self.material = ""
            self.somatic = false
            self.verbal = false
            self.authorPay = int
            spells = []
        }
    }
    
    var unwrap: Component {
        if somatic {
            .somatic
        } else if verbal {
            .verbal
        } else if authorPay > 0 {
            .authorPay(authorPay)
        } else {
            .material(material)
        }
    }
}
