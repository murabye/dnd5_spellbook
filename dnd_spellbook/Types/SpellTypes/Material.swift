//
//  Material.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation
import SwiftData

@Model
class Material: Codable {
    
    @Attribute(.unique) let id: String
    let cost: Int
    let name: String
    
    init(
        id: String,
        cost: Int,
        name: String
    ) {
        self.id = id
        self.cost = cost
        self.name = name
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.cost = try container.decode(Int.self, forKey: .cost)
        self.name = try container.decode(String.self, forKey: .name)
    }
}
    
extension Material: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(cost)
        hasher.combine(name)
    }
}

extension Material {
    
    enum CodingKeys: String, CodingKey {
        case id
        case cost
        case name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(cost, forKey: .cost)
        try container.encode(name, forKey: .name)
    }
}
