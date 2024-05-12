//
//  TagExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation

class CustomTagExportModel: Codable {
    
    let id: String
    let text: String
    let emoji: String
    let color: TagColor
        
    init(from tag: Tag) {
        self.id = tag.id
        self.text = tag.text
        self.emoji = tag.emoji
        self.color = tag.color
    }
}
