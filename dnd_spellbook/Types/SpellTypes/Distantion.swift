//
//  Distantion.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation

enum Distantion {
    
    case onlyYou
    case touches
    case visibility
    case full
    case feet(Int)
}

extension Distantion: HaveName {
    
    var name: String {
        switch self {
        case .onlyYou: "На вас"
        case .touches: "Касание"
        case .visibility: "В пределах видимости"
        case .full: "Неограниченая"
        case let .feet(num): "\(num)фут"
        }
    }
}
 
extension Distantion: Equatable {
    
    static func == (lhs: Distantion, rhs: Distantion) -> Bool {
        switch (lhs, rhs) {
        case  (.onlyYou, .onlyYou): true
        case  (.touches, .touches): true
        case  (.visibility, .visibility): true
        case  (.full, .full): true
        case let (.feet(lhsFeet), .feet(rhsFeet)): lhsFeet == rhsFeet
        default: false
        }
    }
}

extension Distantion: Hashable {

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .feet(feet):
            hasher.combine("feet")
            hasher.combine(feet)
        case .full:
            hasher.combine("full")
        case .onlyYou:
            hasher.combine("onlyYou")
        case .touches:
            hasher.combine("touches")
        case .visibility:
            hasher.combine("visibility")
        }
    }
}

extension Distantion: Codable {
    
    enum CodingKeys: String, CodingKey {

        case onlyYou
        case touches
        case feet
        case visibility
        case full
    }
    
    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let onlyYou = try container.decodeIfPresent(Bool.self, forKey: .onlyYou)
        let touches = try container.decodeIfPresent(Bool.self, forKey: .touches)
        let visibility = try container.decodeIfPresent(Bool.self, forKey: .visibility)
        let full = try container.decodeIfPresent(Bool.self, forKey: .full)
        let feet = try container.decodeIfPresent(Int.self, forKey: .feet)
        
        if onlyYou != nil {
            self = .onlyYou
        } else if touches != nil {
            self = .touches
        } else if let feet {
            self = .feet(feet)
        } else if full != nil {
            self = .full
        } else if visibility != nil {
            self = .visibility
        } else {
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .onlyYou:
            try container.encode(true, forKey: .onlyYou)
        case .touches:
            try container.encode(true, forKey: .touches)
        case .visibility:
            try container.encode(true, forKey: .visibility)
        case let .feet(feetNum):
            try container.encode(feetNum, forKey: .feet)
        case .full:
            try container.encode(true, forKey: .full)
        }
    }
}
