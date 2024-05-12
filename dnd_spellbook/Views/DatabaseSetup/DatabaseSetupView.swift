//
//  DatabaseSetupView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 10.02.2024.
//

import SwiftData
import SwiftUI

struct DatabaseSetupView: View {
    
    enum AnyError: Error {
        case anyError
    }

    @Environment(\.modelContext) var modelContext
    @Binding var stage: Stage

    enum Stage: CGFloat {
        case error = 1
        case preparing
        case parseTags
        case writeTags
        case parseMaterials
        case writeMaterials
        case parseSpells
        case writeSpells
        case connectSpells
        case generateFilters
        case done
        
        var text: String {
            switch self {
            case .error: "Ошибка 😭"
            case .preparing: "Подготовка ⚙️"
            case .parseTags: "Расшифровываем теги 💡"
            case .writeTags: "Записываем теги 🔥"
            case .parseMaterials: "Расшифровываем материалы 📇"
            case .writeMaterials: "Записываем материалы 📦"
            case .parseSpells: "Расшифровываем заклинания 📚"
            case .writeSpells: "Записываем заклинания 📖"
            case .connectSpells: "Соединяем в магию 🧙‍♂️"
            case .generateFilters: "Собираем фильтры 📋"
            case .done: "Настройка завершена"
            }
        }
    }

    var body: some View {
        VStack {
            if stage == .error {
                Text("❌").font(.system(size: 60))
            } else {
                ProgressView(value: stage.rawValue, total: 10)
                    .foregroundColor(.blue)
                    .padding(30)
            }
            Text(stage.text)
        }
        .appearOnce {
            Task.detached { @MainActor in
                do {
                    try save(tags: try parseTags())
                    try save(materials: parseMaterials())
                    let presets = try parseSpells()
                    let spells = try connect(presets)
                    try save(spells: spells)
                    try pregenerateFilters()
                    self.stage = .done
                } catch let error {
                    self.stage = .error
                }
            }
        }
    }

    func parseTags() throws  -> [Tag] {
        self.stage = .parseTags
        if let bundlePath = Bundle.main.path(forResource: "tags", ofType: "json"),
           let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return try JSONDecoder().decode([Tag].self, from: jsonData)
        } else {
            throw AnyError.anyError
        }
    }
    
    func save(tags: [Tag]) throws {
        self.stage = .writeTags
        try modelContext.transaction {
            for tag in tags {
                modelContext.insert(tag)
            }
            
            try modelContext.save()
        }
    }

    func parseMaterials() throws -> [MaterialModel]  {
        self.stage = .parseMaterials
        if let bundlePath = Bundle.main.path(forResource: "materials", ofType: "json"),
           let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return try JSONDecoder().decode([MaterialModel].self, from: jsonData)
        } else {
            throw AnyError.anyError
        }
    }
    
    func save(materials: [MaterialModel]) throws {
        self.stage = .writeMaterials
        try modelContext.transaction {
            for material in materials {
                modelContext.insert(material)
            }
        
            try modelContext.save()
        }
    }
    
    func parseSpells() throws -> [SpellPreset] {
        self.stage = .parseSpells
        if let bundlePath = Bundle.main.path(forResource: "skills", ofType: "json"),
           let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return try JSONDecoder().decode([SpellPreset].self, from: jsonData)
        } else {
            throw AnyError.anyError
        }
    }
        
    func connect(_ presets: [SpellPreset]) throws -> [Spell] {
        self.stage = .connectSpells
        var res = [Spell]()
        
        for preset in presets {

            var fetchDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { tag in
                preset.initialTagsIds.contains(tag.id)
            })
            fetchDescriptor.fetchLimit = preset.initialTagsIds.count
            let tags = try modelContext.fetch(fetchDescriptor)
            
            let spell = Spell(
                id: preset.id,
                name: preset.name,
                labelling: preset.labelling,
                concentration: preset.concentration,
                duration: preset.duration,
                level: preset.level,
                components: preset.components,
                distantion: preset.distantion,
                typeOfAction: preset.typeOfAction,
                school: preset.school,
                source: preset.sources,
                userDescription: nil,
                initialTags: tags,
                userTagsActions: [],
                classes: preset.classes,
                isCustom: false,
                isHidden: false,
                canUpcast: preset.canUpcast
            )

            res.append(spell)
        }
        
        return res
    }
    
    func save(spells: [Spell]) throws {
        self.stage = .writeSpells
        try modelContext.transaction {
            for spell in spells {
                modelContext.insert(spell)
            }
            
            try modelContext.save()
        }
    }
    
    func pregenerateFilters() throws {
        self.stage = .generateFilters
        let filters = [
            Filter.free,
            Filter.phb,
            Filter.bonus,
            Filter.mainAction,
            Filter.noConcentration,
            Filter.noSound,
            Filter.noHand
        ]
        
        try modelContext.transaction {
            for filter in filters {
                modelContext.insert(filter)
            }
            
            try modelContext.save()
        }
    }
}

struct SpellPreset: Codable {

    let id: String
    let name: String
    let labelling: String
    let concentration: Bool
    let duration: Duration
    let level: Int
    let distantion: Distantion
    let typeOfAction: TypeOfAction
    let school: SpellSchool
    let sources: [Sources]
    let initialTagsIds: [String]
    let classes: [CharacterClass]
    let components: [Component]
    let canUpcast: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case labelling
        case concentration
        case duration
        case level
        case distantion
        case typeOfAction
        case school
        case sources = "source"
        case initialTagsIds = "initialTags"
        case classes
        case components
        case canUpcast = "canUpcast"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.labelling = try container.decode(String.self, forKey: .labelling)
        self.concentration = try container.decode(Bool.self, forKey: .concentration)
        self.duration = try container.decode(Duration.self, forKey: .duration)
        self.level = try container.decode(Int.self, forKey: .level)
        self.distantion = try container.decode(Distantion.self, forKey: .distantion)
        self.typeOfAction = try container.decode(TypeOfAction.self, forKey: .typeOfAction)
        self.school = try container.decode(SpellSchool.self, forKey: .school)
        self.initialTagsIds = try container.decode([String].self, forKey: .initialTagsIds)
        self.classes = try container.decode([CharacterClass].self, forKey: .classes)
        self.components = try container.decode([Component].self, forKey: .components)
        
        let sourcesOne = [(try? container.decode(Sources.self, forKey: .sources))].compactMap { $0 }
        let sourcesMultiple = try? container.decode([Sources].self, forKey: .sources)
        self.sources = sourcesMultiple ?? sourcesOne
        self.canUpcast = (try? container.decode(Bool.self, forKey: .canUpcast)) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(labelling, forKey: .labelling)
        try container.encode(duration, forKey: .duration)
        try container.encode(level, forKey: .level)
        try container.encode(components, forKey: .components)
        try container.encode(distantion, forKey: .distantion)
        try container.encode(typeOfAction, forKey: .typeOfAction)
        try container.encode(school, forKey: .school)
        try container.encode(sources, forKey: .sources)
        try container.encode(initialTagsIds, forKey: .initialTagsIds)
        try container.encode(classes, forKey: .classes)
        try container.encode(concentration, forKey: .concentration)
        try container.encode(canUpcast, forKey: .canUpcast)
    }
}
