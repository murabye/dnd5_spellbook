//
//  TypeOfActionExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation

class TypeOfActionExportModel: Codable {
    
    let action: Bool
    let bonus: Bool
    let reaction: Bool
    let time: Int
    
    init(typeOfAction: TypeOfActionModel) {
        self.action = typeOfAction.action
        self.bonus = typeOfAction.bonus
        self.reaction = typeOfAction.reaction
        self.time = typeOfAction.time
    }
    
    var typeOfAction: TypeOfAction {
        if action {
            return .action
        } else if bonus {
            return .bonus
        } else if reaction {
            return .reaction
        } else {
            return .time(minutes: time)
        }
    }
}
