//
//  TypeOfAction.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation

enum NoConreteActionType: Int, Codable, FilterFormSelectable, CaseIterable {
    
    case action
    case bonus
    case reaction
    case time
}

extension NoConreteActionType: HaveName {

    var name: String {
        switch self {
        case .action: "Действие"
        case .bonus: "Бонусное"
        case .reaction: "Реакция"
        case .time: "Минуты"
        }
    }
}

enum TypeOfAction {
    
    case action
    case bonus
    case reaction
    case time(minutes: Int)
}

extension TypeOfAction: HaveName {

    var name: String {
        switch self {
        case .action: "Действие"
        case .bonus: "Бонусное действие"
        case .reaction: "Реакция"
        case let .time(minutes): "\(minutes) минут"
        }
    }
}

extension TypeOfAction: Comparable {
    
    var order: Int {
        switch self {
        case .action:
            0
        case .bonus:
            1
        case .reaction:
            2
        case .time(let minutes):
            3 + minutes
        }
    }
    
    static func < (lhs: TypeOfAction, rhs: TypeOfAction) -> Bool {
        lhs.order < rhs.order
    }
}

extension TypeOfAction: Codable {
    
    enum CodingKeys: String, CodingKey {
        case action
        case bonus
        case reaction
        case time

    }
    
    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = try container.decodeIfPresent(Int.self, forKey: .action)
        let bonus = try container.decodeIfPresent(Int.self, forKey: .bonus)
        let reaction = try container.decodeIfPresent(Int.self, forKey: .reaction)
        let time = try container.decodeIfPresent(Int.self, forKey: .time)
        
        if action != nil {
            self = .action
        } else if bonus != nil {
            self = .bonus
        } else if reaction != nil {
            self = .reaction
        } else if let time {
            self = .time(minutes: time)
        } else {
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .action:
            try container.encode(1, forKey: .action)
        case .bonus:
            try container.encode(1, forKey: .bonus)
        case .reaction:
            try container.encode(1, forKey: .reaction)
        case let .time(minutes):
            try container.encode(minutes, forKey: .time)
        }
    }
}
