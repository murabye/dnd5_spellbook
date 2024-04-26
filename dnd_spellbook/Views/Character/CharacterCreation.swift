//
//  ContentView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

struct CharacterCreationView: View {
    enum Constants {
        static let islandCollapsableItemKey = "islandCollapsableItemKey"
    }
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var isLoading: Bool
    
    let safeArea: EdgeInsets

    @State private var selectedImage: UIImage? = nil
    @State private var characterName: String = ""
    @State private var selectedClass: CharacterClass = .nothing
    @State private var level: Int = 1

    @State private var isPickerSelected = false
    @State private var scrollOffset: CGFloat = 0.0
    @State private var autoKnownSpells = [Spell]()
    @State private var paginationOffset: Int = 0
    @State private var allCleaned = false

    var body: some View {
        ZStack {
            ObservableScrollView(scrollOffset: $scrollOffset) { _ in
                imagePickerView
                VStack {
                    TextField("Имя", text: $characterName)
                        .padding(.bottom, 6)
                        .padding(.top, 3)
                    Picker(level.levelName, selection: $level) {
                        ForEach(0...9, id: \.self) {
                            Text($0.levelName)
                        }
                    }
                    .pickerStyle(.menu)

                    Divider()
                    classPicker
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.systemGroupedTableContent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                if !autoKnownSpells.isEmpty {
                    autoSpellsHeader.padding(.horizontal)
                    autoSpellsList.padding(.horizontal)
                }
                
                LazyVStack {
                    Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadSpells() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
                        
            if isLoading {
                LoaderBlock()
            }
        }
        .animation(.easeIn, value: selectedClass)
        .sheet(isPresented: $isPickerSelected) {
            UIPickerView(image: $selectedImage)
                .ignoresSafeArea()
        }
        .mergingDynamicIslandWithView(
            forKey: Constants.islandCollapsableItemKey,
            safeArea: safeArea,
            backgroundColor: Color(uiColor: .systemGroupedBackground)
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                cancelButton
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                applyButton
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onChange(of: selectedClass, { _, _ in
            allCleaned = false
            autoKnownSpells = []
            paginationOffset = 0
            loadSpells()
        })
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    var imagePickerView: some View {
        CharacterImagePickerView(
            isPickerSelected: $isPickerSelected,
            selectedImage: $selectedImage,
            scrollOffset: $scrollOffset
        )
    }
    
    var classPicker: some View {
        Picker("Класс", selection: $selectedClass) {
            ForEach(CharacterClass.allCases, id: \.self) { value in
                if value != .nothing {
                    Text(value.name)
                } else {
                    Text("Другой")
                }
            }
        }
        .pickerStyle(.menu)
    }
    
    var autoSpellsHeader: some View {
        HStack {
            Text("Известные автоматически")
            Spacer()
            Button("Забыть все", action: {
                self.allCleaned = true
                self.autoKnownSpells = [];
                self.paginationOffset = Int.max
            })
        }
    }

    var autoSpellsList: some View {
        LazyVStack {
            ForEach(
                autoKnownSpells,
                id: \.id
            ) { spell in
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
        
    var applyButton: some View {
        Button("Save", action: { addCharacter(); dismiss() })
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
            tagActions: [:],
            knownSpells: [],
            preparedSpells: []
        )
        modelContext.insert(character)
        
        addFilters(for: level, characterId: newCharacterId)
        if level < 9 {
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
                    tagActions: [:],
                    knownSpells: [],
                    preparedSpells: []
                )
                modelContext.insert(character)
                
                addFilters(for: level, characterId: newCharacterId)
                if level < 9 {
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
}
