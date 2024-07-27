//
//  ImportView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import SwiftData
import SwiftUI

struct CharacterImportView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var fileImporting = false
    @State private var string = ""
    @State private var isError = false {
        didSet {
            guard isError else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                isError = false
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button("Из файла") {
                        fileImporting = true
                    }
                    Button("Из строки") {
                        importCharacter(string: string)
                    }
                    .disabled(string.isEmpty)
                    
                    if isError {
                        Text("Произошла ошибка...")
                    }
                }
                
                TextField("Строка экспорта", text: $string, axis: .vertical)
                    .autocorrectionDisabled()
                
                Spacer()
            }
            .toolbar {
                cancelButton
            }
            .navigationTitle("Импорт")
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .fileImporter(
            isPresented: $fileImporting,
            allowedContentTypes: [.plainText]
        ) { result in
            switch result {
            case .success(let file):
                guard let val = try? String(contentsOf: file, encoding: .utf8) else {
                    isError = false
                    return
                }
                importCharacter(string: val)
            case .failure:
                isError = true
            }
        }
    }
    
    var cancelButton: some View {
        Button("", systemImage: "xmark", action: { dismiss() })
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }

    func importCharacter(string: String) {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8),
              let model = try? decoder.decode(CharacterExportModel.self, from: data) else {
            isError = true
            return
        }
        
        let imageUrl: URL?
        if let imgData = model.image,
            let png = UIImage(data: imgData) {
            imageUrl = FileManager.default.save(image: png)
        } else {
            imageUrl = nil
        }
        
        let newId = UUID().uuidString
        let character = CharacterModel(
            id: newId,
            imageUrl: imageUrl,
            characterClass: model.characterClass,
            name: model.name, 
            levels: model.levels, 
            usedLevels: model.usedLevels
        )
        modelContext.insert(character)
        try? modelContext.save()
                
        model
            .relationships
            .compactMap { exportModel -> CharacterToSpell? in
                let id = exportModel.spellId
                let descriptor = FetchDescriptor<Spell>(predicate: #Predicate { spell in spell.id == id })
                guard let spell = (try? modelContext.fetch(descriptor))?.first else { return nil }
                return CharacterToSpell(
                    characterId: newId,
                    spellId: exportModel.spellId, 
                    spellLevel: spell.level,
                    isLocked: exportModel.isLocked,
                    isSpellCustom: false,
                    typeOfRelation: exportModel.typeOfRelation,
                    spell: spell
                )
            }
            .forEach { modelContext.insert($0) }

        try? modelContext.save()
        
        model
            .customSpellsRelationships
            .forEach { exportModel in
                let spell = spell(model: exportModel)
                modelContext.insert(spell)
                
                let relationship = CharacterToSpell(
                    characterId: newId,
                    spellId: exportModel.id, 
                    spellLevel: spell.level,
                    isLocked: exportModel.isLockedRelationship, 
                    isSpellCustom: true,
                    typeOfRelation: exportModel.relationType,
                    spell: spell
                )
                modelContext.insert(relationship)
            }
        try? modelContext.save()

        UserDefaults.standard.selectedId = newId
        CharacterUpdateService.send()
        dismiss()
    }
    
    func spell(model: CustomSpellExportModel) -> Spell {
        let initialTags = model.initialTags.compactMap { tag(id: $0) }
        let customTags = model.customTags.compactMap { tag(model: $0) }
        let new = Spell(
            id: model.id,
            name: model.name,
            engName: model.engName,
            labelling: model.labelling,
            concentration: model.concentration,
            duration: model.durationModel.duration,
            level: model.level,
            components: model.componentsModel.map { $0.component },
            distantion: model.distantionModel.distantion,
            typeOfAction: model.typeOfActionModel.typeOfAction,
            school: model.school,
            source: model.sources,
            initialTags: initialTags + customTags,
            userTagsActions: [],
            classes: model.classes,
            isCustom: true,
            isHidden: false,
            canUpcast: model.canUpcast
        )
        modelContext.insert(new)
        return new
    }
    
    func tag(id: String) -> Tag? {
        var fetchDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { tag in
            tag.id == id
        })
        fetchDescriptor.fetchLimit = 1
        return try? modelContext.fetch(fetchDescriptor).first
    }
    
    func tag(model: CustomTagExportModel) -> Tag {
        var fetchDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { tag in
            tag.text == model.text
        })
        fetchDescriptor.fetchLimit = 1
        if let existing = try? modelContext.fetch(fetchDescriptor).first {
            return existing
        }

        let new = Tag(
            id: UUID().uuidString,
            text: model.text,
            emoji: model.emoji,
            isCustom: true,
            color: model.color
        )
        modelContext.insert(new)
        return new
    }
}
