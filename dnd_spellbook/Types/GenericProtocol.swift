//
//  GenericProtocol.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import Foundation

protocol FilterFormSelectable: HaveName, Equatable {
}

protocol HaveName {
    var name: String { get }
}

protocol HaveDescription {
    static var description: String { get }
}

protocol Archetype: CaseIterable, Hashable, HaveDescription, HaveName { }
