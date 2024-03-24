//
//  Tag.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation
import SwiftData

@Model
class Tag: Codable {
    @Relationship(inverse: \Spell.initialTags) var spells: [Spell]
    @Attribute(.unique) let id: String
    let text: String
    let emoji: String
    let isCustom: Bool
    let color: TagColor
    
    init(id: String, text: String, emoji: String, isCustom: Bool, color: TagColor) {
        self.id = id
        self.text = text
        self.emoji = emoji
        self.isCustom = isCustom
        self.color = color
        spells = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.emoji = try container.decode(String.self, forKey: .emoji)
        self.isCustom = try container.decode(Bool.self, forKey: .isCustom)
        self.color = try container.decode(TagColor.self, forKey: .color)
        spells = []
    }
}

extension Tag: Comparable {

    static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.text < rhs.text
    }
}

extension Tag: Equatable {
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
        && lhs.text == rhs.text
        && lhs.isCustom == rhs.isCustom
        && lhs.emoji == rhs.emoji
    }
}

extension Tag: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Tag {
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case emoji
        case isCustom
        case color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(isCustom, forKey: .isCustom)
        try container.encode(color, forKey: .color)
    }
}
