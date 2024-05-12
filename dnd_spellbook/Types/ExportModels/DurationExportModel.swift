//
//  DurationExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation

class DurationExportModel: Codable {
    
    let isInstantly: Bool
    let isRaundes: Bool
    let isTime: Bool
    let isClause: Bool
    let isMany: Bool
    let number: Int

    init(duration: DurationModel) {
        self.isInstantly = duration.isInstantly
        self.isRaundes = duration.isRaundes
        self.isTime = duration.isTime
        self.isClause = duration.isClause
        self.isMany = duration.isMany
        self.number = duration.number
    }
    
    var duration: Duration {
        if isInstantly {
            return .instantly
        } else if isRaundes {
            return .raundes(number)
        } else if isTime {
            return .time(minutes: number)
        } else if isClause {
            return .clause
        } else if isMany {
            return .many
        }
    }
}
