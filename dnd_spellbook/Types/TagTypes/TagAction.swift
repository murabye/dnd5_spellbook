//
//  TagAction.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import SwiftData
import Foundation

@Model
class TagAction {

    // false = remove, true = append
    var action: Bool
    var tagId: String
    @Relationship(deleteRule: .cascade, inverse: \Spell.userTagsActions) var spells: [Spell]
    
    init(action: Bool, tagId: String) {
        self.action = action
        self.tagId = tagId
        self.spells = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(Bool.self, forKey: .action)
        self.tagId = try container.decode(String.self, forKey: .tagId)
        self.spells = []
    }
}

extension TagAction: Equatable { }
extension TagAction: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(action)
        hasher.combine(tagId)
    }
}


extension TagAction: Codable {
    enum CodingKeys: String, CodingKey {
        case action
        case tagId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(tagId, forKey: .tagId)
    }
}

extension [TagAction] {
    
    func applied(to current: [Tag], fullList: [Tag]) -> [Tag] {
        var res = current
        
        for tagAction in self {
            if tagAction.action {
                if let tag = fullList.first(where: { $0.id == tagAction.tagId }) {
                    res.append(tag)
                }
            } else {
                if let tag = fullList.first(where: { $0.id == tagAction.tagId }),
                   let index = res.firstIndex(of: tag) {
                    res.remove(at: index)
                }
            }
        }
                
        return res
    }
}
