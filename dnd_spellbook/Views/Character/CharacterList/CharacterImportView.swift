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
        
        let initialKnown = model.knownSpells.compactMap { spell(id: $0) }
        let customKnown = model.customKnownSpells.compactMap { spell(model: $0) }
        
        let initialPrepared = model.preparedSpells.compactMap { spell(id: $0) }
        let customPrepared = model.customPreparedSpells.compactMap { spell(model: $0) }

        let newId = UUID().uuidString
        let character = CharacterModel(
            id: newId,
            imageUrl: imageUrl,
            characterClass: model.characterClass,
            name: model.name, 
            level: model.level,
            knownSpells: initialKnown + customKnown,
            preparedSpells: initialPrepared + customPrepared
        )
        modelContext.insert(character)
        UserDefaults.standard.selectedId = newId
        try? modelContext.save()
        CharacterUpdateService.send()
        dismiss()
    }
    
    func spell(id: String) -> Spell? {
        var fetchDescriptor = FetchDescriptor<Spell>(predicate: #Predicate { spell in
            spell.id == id
        })
        fetchDescriptor.fetchLimit = 1
        return try? modelContext.fetch(fetchDescriptor).first
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
