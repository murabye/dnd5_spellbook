//
//  SpellCreationView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.12.2023.
//

import SwiftData
import SwiftUI

struct SpellCreationView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State var name: String = ""
    
    @State var tags: [Tag] = []
    @State var isTagCreationPresented: Bool = false
    
    @State var duration: Duration = .instantly
    @State var distantion: Distantion = .onlyYou
    @State var description: String = ""
    @State var classes: [CharacterClass] = []
    @State var source: [Sources] = []
    @State var school: SpellSchool = .evocation
    @State var level: Int = 0
    @State var concentration: Bool = false
    @State var typeOfAction: TypeOfAction = .action
    @State var components: [ComponentCreationElement] = []
    
    @Query(sort: \Tag.text) var allTags: [Tag]
    @Query(sort: \MaterialModel.name) var allMaterials: [MaterialModel]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Название заклинания", text: $name, axis: .vertical)
                    TagLine(compact: false, edit: true, tags: $tags) {
                        isTagCreationPresented.toggle()
                    }
                    .popover(isPresented: $isTagCreationPresented) {
                        TagSelectView(selectedTags: $tags)
                    }
                    
                    HStack {
                        DurationPickerView(selectedDuration: $duration)
                        Spacer()
                        DistantionPickerView(selectedDistantion: $distantion)
                    }
                    
                    Toggle("Концентрация", isOn: $concentration)
                    
                    ComponentCreationView(selectedComponents: $components)                    
                    MultipleElemsMenu(selected: $classes, notSelectedTitle: "Класс", all: CharacterClass.allCases)
                    
                    HStack {
                        TypeOfActionPickerView(selectedType: $typeOfAction)                        
                        Spacer()
                        Picker(school.name, selection: $school) {
                            ForEach(SpellSchool.allCases, id: \.self) {
                                Text($0.name)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    TextField("Описание", text: $description, axis: .vertical)
                    
                    HStack {
                        MultipleElemsMenu(selected: $source, notSelectedTitle: "Источники", all: Sources.allCases)
                        Spacer()
                        Picker(level.levelName, selection: $level) {
                            ForEach(0...9, id: \.self) {
                                Text($0.levelName)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .contentShape(Rectangle())
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Создание заклинания")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("", systemImage: "xmark") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveUpdate()
                        dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }

    func saveUpdate() {
        guard !name.isEmpty,
              !description.isEmpty else {
            return
        }

        var resultComponents = [Component]()
        var materials = [MaterialModel]()
        
        for creationComponent in components {
            switch creationComponent {
            case .somatic:
                resultComponents.append(.somatic)
            case .verbal:
                resultComponents.append(.verbal)
            case let .authorPay(price):
                resultComponents.append(.authorPay(price))
            case let .material(name, price):
                let id = UUID().uuidString
                materials.append(MaterialModel(id: id, cost: price, name: name))
                resultComponents.append(.material(id))
            }
        }
        
        let spell = Spell(
            id: UUID().uuidString,
            name: name,
            labelling: "",
            concentration: concentration,
            duration: duration,
            level: level,
            components: resultComponents,
            distantion: distantion,
            typeOfAction: typeOfAction,
            school: school,
            source: source,
            userDescription: description,
            initialTags: tags,
            userTagsActions: [],
            classes: classes,
            isCustom: true,
            isHidden: false
        )
        
        for material in materials {
            modelContext.insert(material)
        }
        
        modelContext.insert(spell)
        try? modelContext.save()
    }
}

#Preview {
    MainActor.assumeIsolated {
        SpellCreationView()
    }
}
