//
//  Component.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 26.12.2023.
//

import Foundation

enum Component {
    
    case material(String)
    case somatic
    case verbal
    case authorPay(Int)
}


extension Component: Comparable {
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .somatic: return true
        case .verbal: if rhs != .somatic { return true }
        case .authorPay: if rhs != .somatic && rhs != .verbal { return true }
        default: break
        }
        
        switch (lhs, rhs) {
        case (.somatic, .somatic):
            return false
        case (.verbal, .verbal):
            return false
        case (.material, .material):
            return false
        case (.authorPay, .authorPay):
            return false
        default:
            return false
        }
    }
}

extension Component: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.material, .material): true
        case (.somatic, .somatic): true
        case (.verbal, .verbal): true
        case (.authorPay, .authorPay): true
        default: false
        }
    }
}

extension Component: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .material(material):
            hasher.combine("material")
            hasher.combine(material)
        case .somatic:
            hasher.combine("somatic")
        case .verbal:
            hasher.combine("verbal")
        case let .authorPay(pay):
            hasher.combine("authorPay")
            hasher.combine(pay)
        }
    }
}

extension Component: Codable {
    
    enum CodingKeys: String, CodingKey {
        case material
        case somatic
        case verbal
        case authorPay
    }
    
    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let verbal = try container.decodeIfPresent(Bool.self, forKey: .verbal)
        let somatic = try container.decodeIfPresent(Bool.self, forKey: .somatic)
        let materialInt = try? container.decodeIfPresent([Int].self, forKey: .material)
        let materialStr = try? container.decodeIfPresent([String].self, forKey: .material)
        let authorPay = try container.decodeIfPresent(Int.self, forKey: .authorPay)

        if verbal != nil {
            self = .verbal
        } else if somatic != nil {
            self = .somatic
        } else if let authorPay {
            self = .authorPay(authorPay)
        } else if let materialInt {
            self = .material(materialInt.map { String($0) }.joined())
        } else if let materialStr {
            self = .material(materialStr.joined())
        } else {
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .verbal:
            try container.encode(true, forKey: .verbal)
        case .somatic:
            try container.encode(true, forKey: .somatic)
        case let .authorPay(price):
            try container.encode(price, forKey: .authorPay)
        case let .material(materialIds):
            try container.encode(materialIds, forKey: .material)
        }
    }
}

extension [Component] {
    
    func name(allMaterials: [MaterialModel]) -> String {
        self
            .sorted()
            .map { component in
                switch component {
                case .verbal: return [ "голос" ]
                case .somatic: return [ "руки" ]
                case let .authorPay(price): return [ "авторские отчисления (\(price)зм" ]
                case let .material(materialId):
                    var materials = [String]()
                    if let material = allMaterials.first(where: { $0.id == materialId }) {
                        materials.append(material.name)
                    }
                    return materials
                }
            }
            .flatMap { $0 }
            .joined(separator: ", ")
            .capitalizedSentence
    }
}
