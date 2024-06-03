//
//  Level+.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.05.2024.
//

import Foundation

extension Int {
    
    var levelName: String {
        switch self {
        case 0:
            return "Заговор"
        default:
            return "\(self) круг"
        }
    }
}

typealias LevelList = [Int: Int]

extension LevelList {
    
    var maxLevel: Int {
        Array(keys).max() ?? 0
    }
    
    var sortedList: [(Int, Int)] {
        map { ($0, $1) }
            .filter { $0.1 > 0 }
            .sorted { $0.0 < $1.0 }
    }
}
