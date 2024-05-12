//
//  DistantionExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation

class DistantionExportModel: Codable {
    
    let onlyYou: Bool
    let touches: Bool
    let visibility: Bool
    let full: Bool
    let feet: Int

    init(distantion: DistantionModel) {
        self.onlyYou = distantion.onlyYou
        self.touches = distantion.touches
        self.visibility = distantion.visibility
        self.full = distantion.full
        self.feet = distantion.feet
    }
    
    var distantion: Distantion {
        if onlyYou {
            return .onlyYou
        } else if touches {
            return .touches
        } else if visibility {
            return .visibility
        } else if full {
            return .full
        } else {
            return .feet(feet)
        }
    }
}
