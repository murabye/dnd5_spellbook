//
//  Spell.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 25.12.2023.
//

import Foundation
import SwiftData

@Model
class Spell: HaveName {
    
    @Attribute(.unique) var id: String
    var name: String
    var labelling: String
    var concentration: Bool
    var level: Int
    var school: SpellSchool
    var sources: [Sources]
    var userDescription: String?
    var classes: [CharacterClass]
    var isCustom: Bool
    var isHidden: Bool

    var userTagsActions: [TagAction]
    var typeOfActionModel: TypeOfActionModel
    var distantionModel: DistantionModel
    var durationModel: DurationModel
    var componentsModel: [ComponentsModel]
    var initialTags: [Tag]

    var typeOfAction: TypeOfAction {
        typeOfActionModel.unwrap
    }
    
    var typeOfActionNonConcrete: NoConreteActionType {
        switch typeOfAction {
        case .action: .action
        case .bonus: .bonus
        case .reaction: .reaction
        case .time: .time
        }
    }
    
    var distantion: Distantion {
        distantionModel.unwrap
    }
    
    var duration: Duration {
        durationModel.unwrap
    }

    var components: [Component] {
        componentsModel.map(\.unwrap)
    }
    
    func tags(allTags: [Tag]) -> [Tag] {
        Array(userTagsActions.applied(to: initialTags, fullList: allTags))
    }
    
    var descrText: String {
        if let userText = userDescription,
           !userText.isEmpty {
            userText
        } else {
            labelling
        }
    }
    
    init(
        id: String,
        name: String,
        labelling: String,
        concentration: Bool,
        duration: Duration,
        level: Int,
        components: [Component],
        distantion: Distantion,
        typeOfAction: TypeOfAction,
        school: SpellSchool,
        source: [Sources],
        userDescription: String? = nil,
        initialTags: [Tag],
        userTagsActions: [TagAction],
        classes: [CharacterClass],
        isCustom: Bool,
        isHidden: Bool
    ) {
        self.id = id
        self.name = name
        self.labelling = labelling
        self.concentration = concentration
        self.level = level
        self.school = school
        self.sources = source
        self.userDescription = userDescription
        self.userTagsActions = userTagsActions
        self.classes = classes
        self.isCustom = isCustom
        
        self.typeOfActionModel = TypeOfActionModel(from: typeOfAction)
        self.distantionModel = DistantionModel(from: distantion)
        self.durationModel = DurationModel(from: duration)
        self.initialTags = []
        self.componentsModel = []
        self.isHidden = isHidden
        self.initialTags = []
        self.componentsModel = []
        
        set(tags: initialTags)
        set(components: components)
    }

    func set(tags: [Tag]) {
        self.initialTags.append(contentsOf: tags)
    }
    
    func set(components: [Component]) {
        self.componentsModel = components.map { ComponentsModel(from: $0) }
    }
}

extension Spell: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Spell: Equatable {
    
    static func == (lhs: Spell, rhs: Spell) -> Bool {
        lhs.id == rhs.id
    }
}

extension Spell: Comparable {
    
    static func < (lhs: Spell, rhs: Spell) -> Bool {
        return lhs.name < rhs.name
    }
}
