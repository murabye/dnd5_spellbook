//
//  CharacterCreationBigView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct ColumnReader<Content: View>: View {

    @ViewBuilder var content: (Int, EdgeInsets) -> Content
    var body: some View {
        GeometryReader { proxy in
            content(
                max(Int(proxy.size.width / 300), 1),
                proxy.safeAreaInsets
            )
        }
    }
}

struct CharacterCreationBigView: View {
    enum Constants {
        static let islandCollapsableItemKey = "islandCollapsableItemKey"
    }

    let columnAmount: Int

    @Binding var isLoading: Bool
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var selectedImage: UIImage? = nil
    @State private var characterName: String = ""
    @State private var selectedClass: CharacterClass = .nothing
    @State private var maxLevel: Int = 0
    @State private var levels: LevelList = [:]

    @State private var isPickerSelected = false

    @State var autoKnownSpells = [Spell]()
    @State var paginationOffset: Int = 0
    @State private var allCleaned = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VerticalWaterfallLayout(
                    columns: columnAmount,
                    spacingX: 16,
                    spacingY: 16
                ) {
                    imagePickerView
                    classPicker
                    
                    levelPickerView
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.systemGroupedTableContent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                
                if !autoKnownSpells.isEmpty {
                    autoSpellsHeader.padding(.horizontal)
                    autoKnownSpellsList.padding(.horizontal)
                }
                
                LazyVStack {
                    Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadSpells() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .sheet(isPresented: $isPickerSelected) {
                UIPickerView(image: $selectedImage).ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    applyButton
                }
            }
            .onChange(of: selectedClass, { _, _ in
                autoKnownSpells = []
                paginationOffset = 0
                loadSpells()
                allCleaned = false
            })
            .background(Color(uiColor: .systemGroupedBackground))
            
            if isLoading {
                LoaderBlock()
            }
        }
    }
    
    var levelPickerView: some View {
        VStack {
            Stepper("Ячейки заклинаний", value: $maxLevel, in: 0...9)
                .onChange(of: maxLevel) { oldValue, newValue in
                    if oldValue > newValue {
                        levels[oldValue] = nil
                    } else if oldValue < newValue {
                        levels[newValue] = 1
                    }
                }
            if maxLevel > 0 {
                Divider()
            }
            ForEach(levels.sortedList, id: \.0) { (level, amount) in
                Stepper {
                    HStack {
                        Text(level.levelName)
                        Spacer()
                        Text(String(amount))
                    }
                } onIncrement: {
                    levels[level] = amount + 1
                } onDecrement: {
                    levels[level] = max(amount - 1, 1)
                }
            }
        }
    }

    var imagePickerView: some View {
        VStack {
            Button(action: {
                isPickerSelected = true
            }) {
                Group {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .frame(width: 70, height: 70, alignment: .top)
                            .background()
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "plus")
                            .resizable()
                            .padding()
                            .frame(width: 70, height: 70, alignment: .top)
                            .background()
                            .clipShape(Circle())
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 10)
            }
            
            TextField("Имя", text: $characterName)
                .padding(.bottom, 18)
                .padding(.top, 15)
                .padding(.horizontal)
                .background(Color.systemGroupedTableContent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top)
        }
    }
    
    var classPicker: some View {
        Picker("Класс", selection: $selectedClass) {
            ForEach(CharacterClass.allCases, id: \.self) {
                Text($0.name)
            }
        }
        .pickerStyle(.wheel)
    }
    
    var autoSpellsHeader: some View {
        HStack {
            Text("Известные автоматически")
            Spacer()
            Button("Забыть все", action: {
                self.allCleaned = true
                self.autoKnownSpells = []
                self.paginationOffset = Int.max
            })
        }
    }

    var applyButton: some View {
        Button("Сохранить", action: { addCharacter(); dismiss() })
            .disabled(characterName.isEmpty)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }
    
    var cancelButton: some View {
        Button("", systemImage: "xmark", action: { dismiss() })
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }
    
    func addCharacter() {
        if (selectedClass == .cleric || selectedClass == .druid), !allCleaned {
            addClericOrDruid()
        } else {
            addSimpleCharacter()
        }
    }
    func addSimpleCharacter() {
        isLoading = true
        let imageUrl = FileManager.default.save(image: selectedImage)
        let newCharacterId = UUID().uuidString
        UserDefaults.standard.selectedId = newCharacterId
        let character = CharacterModel(
            id: newCharacterId,
            imageUrl: imageUrl,
            characterClass: selectedClass,
            name: characterName,
            levels: levels, 
            usedLevels: [:],
            knownSpells: [],
            preparedSpells: []
        )
        modelContext.insert(character)
        
        addFilters(for: maxLevel, characterId: newCharacterId)
        if maxLevel < 9 {
            addFilters(for: 9, characterId: newCharacterId)
        }
        
        try? modelContext.save()
        CharacterUpdateService.send()
        isLoading = false
    }
    
    func addClericOrDruid() {
        isLoading = true
        
        let imageUrl = FileManager.default.save(image: selectedImage)
        let fetchDescriptor = FetchDescriptor<Spell>(sortBy: [SortDescriptor(\.id)])
        let allSpells = (try? modelContext.fetch(fetchDescriptor)) ?? []
        
        Task.detached {
            let filter = allSpells.filter { $0.classes.contains(selectedClass) }
            let newCharacterId = UUID().uuidString
            
            Task.detached { @MainActor in
                UserDefaults.standard.selectedId = newCharacterId
                let character = CharacterModel(
                    id: newCharacterId,
                    imageUrl: imageUrl,
                    characterClass: selectedClass,
                    name: characterName,
                    levels: levels, 
                    usedLevels: [:],
                    knownSpells: [],
                    preparedSpells: []
                )
                modelContext.insert(character)
                
                addFilters(for: maxLevel, characterId: newCharacterId)
                if maxLevel < 9 {
                    addFilters(for: 9, characterId: newCharacterId)
                }
                
                try? modelContext.save()
                
                character.knownSpells = filter
                try? modelContext.save()

                CharacterUpdateService.send()
                isLoading = false
            }
        }
    }

    func addFilters(for level: Int, characterId: String) {
        let text: String
        if level < 9 {
            text = "\(characterName) \(selectedClass.name) до \(level) круга"
        } else {
            text = "\(characterName) \(selectedClass.name)"
        }
        let fetchDescriptorLevel = FetchDescriptor<Filter>(predicate: #Predicate { filter in
            filter.name.localizedStandardContains(text)
        })
        let existingFiltersCount: Int = (try? modelContext.fetchCount(fetchDescriptorLevel)) ?? 0
        let filterPresetLevel = Filter.filterForClass(
            name: characterName,
            characterClass: selectedClass,
            level: level,
            copy: existingFiltersCount,
            characterId: characterId
        )
        modelContext.insert(filterPresetLevel)
    }

    func loadSpells() {
        guard (selectedClass == .cleric || selectedClass == .druid), !allCleaned else {
            return
        }

        var fetchDescriptor = FetchDescriptor<Spell>(sortBy: [SortDescriptor(\.id)])
        guard let totalAmount = try? modelContext.fetchCount(fetchDescriptor) else { // заинитить один раз!
            return
        }

        fetchDescriptor.fetchLimit = 50
        fetchDescriptor.fetchOffset = min(totalAmount, paginationOffset)
        
        if totalAmount > paginationOffset + 1 {
            let newData = (try? modelContext.fetch(fetchDescriptor)) ?? []
            paginationOffset += newData.count
            autoKnownSpells.append(contentsOf: newData.filter { $0.classes.contains(selectedClass) })
        }
    }
    
    var autoKnownSpellsList: some View {
        VerticalWaterfallLayout(
            columns: columnAmount,
            spacingX: 16,
            spacingY: 16
        ) {
            ForEach(autoKnownSpells, id: \.id) { spell in
                SpellView(
                    spell: spell,
                    collapsed: true
                )
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.systemGroupedTableContent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical, 2)
                .contextMenu {
                    Button("Забыть", action: { [weak spell] in
                        if let spell,
                           let index = autoKnownSpells.firstIndex(of: spell) {
                            autoKnownSpells.remove(at: index)
                        }
                    })
                }
            }
        }
    }
}
