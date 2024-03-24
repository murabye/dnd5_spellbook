//
//  Duration.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 25.12.2023.
//

import Foundation

enum Duration {
    case instantly
    case raundes(Int)
    case time(minutes: Int)
    case clause
    case many
}

extension Duration: HaveName {
    
    var name: String {
        switch self {
        case .instantly: "Мгновенно"
        case .clause: "Пока не рассеется"
        case .many: "Особая"
        case let .time(minutes): "\(minutes) мин"
        case let .raundes(raundesCount): "\(raundesCount) раунд"
        }
    }
}

extension Duration: Equatable {

    static func == (lhs: Duration, rhs: Duration) -> Bool {
        switch (lhs, rhs) {
        case  (.instantly, .instantly): 
            true
        case (.clause, .clause):
            true
        case (.many, .many):
            true
        case let (.time(lhsMinutes), .time(rhsMinutes)):
            lhsMinutes == rhsMinutes
        case let (.raundes(lhsRaundes), .raundes(rhsRaundes)): 
            lhsRaundes == rhsRaundes
        default: 
            false
        }
    }
}

extension Duration: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .time(minutes):
            hasher.combine("time")
            hasher.combine(minutes)
        case let .raundes(raundes):
            hasher.combine("raundes")
            hasher.combine(raundes)
        case .instantly:
            hasher.combine("instantly")
        case .many:
            hasher.combine("many")
        case .clause:
            hasher.combine("clause")
        }
    }
}

extension Duration: Codable {
    
    enum CodingKeys: String, CodingKey {
        case instantly
        case raundes
        case time
        case clause
        case many
    }
    
    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let instantly = try container.decodeIfPresent(Bool.self, forKey: .instantly)
        let clause = try container.decodeIfPresent(Bool.self, forKey: .clause)
        let many = try container.decodeIfPresent(Bool.self, forKey: .many)
        let raundes = try container.decodeIfPresent(Int.self, forKey: .raundes)
        let time = try container.decodeIfPresent(Int.self, forKey: .time)

        if instantly != nil {
            self = .instantly
        } else if clause != nil {
            self = .clause
        } else if many != nil {
            self = .many
        } else if let raundes {
            self = .raundes(raundes)
        } else if let time {
            self = .time(minutes: time)
        } else {
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .clause:
            try container.encode(true, forKey: .clause)
        case .many:
            try container.encode(true, forKey: .many)
        case .instantly:
            try container.encode(true, forKey: .instantly)
        case let .time(minutes):
            try container.encode(minutes, forKey: .time)
        case let .raundes(number):
            try container.encode(number, forKey: .raundes)
        }
    }
}
