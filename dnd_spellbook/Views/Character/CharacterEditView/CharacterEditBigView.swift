//
//  CharacterEditBigView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct CharacterEditBigView: View {
    enum Constants {
        static let islandCollapsableItemKey = "islandCollapsableItemKey"
    }

    let columnAmount: Int

    @Binding var isLoading: Bool
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    let characterId: String
    let initialImageUrl: URL?
    let initialCharacterName: String
    let selectedClass: CharacterClass
    let initialPrepared: [Spell]
    let initialKnown: [Spell]
    
    @State var imageWasUpdated: Bool = false
    @State var selectedImage: UIImage? = nil
    @State var characterName: String
    @State var maxLevel: Int = 0
    @State var levels: LevelList = [:]
    @State var initialUsedLevels: LevelList

    @State var isPickerSelected = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VerticalWaterfallLayout(
                    columns: columnAmount,
                    spacingX: 16,
                    spacingY: 16
                ) {
                    imagePickerView
                    
                    levelPickerView
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.systemGroupedTableContent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
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
                if let selectedImage {
                    Group {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .frame(width: 70, height: 70, alignment: .top)
                            .background()
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 10)
                } else if let initialImageUrl {
                    Group {
                        AsyncImage(url: initialImageUrl)
                            .frame(width: 70, height: 70, alignment: .top)
                            .background()
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 10)
                } else {
                    Group {
                        Image(systemName: "plus")
                            .resizable()
                            .padding()
                            .frame(width: 70, height: 70, alignment: .top)
                            .background()
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 10)
                }
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
        isLoading = true
        let imageUrl = FileManager.default.save(image: selectedImage)
        removeOldCharacters()
        while initialUsedLevels.maxLevel > levels.maxLevel {
            initialUsedLevels[maxLevel] = nil
        }
        let character = CharacterModel(
            id: characterId,
            imageUrl: imageUrl ?? initialImageUrl,
            characterClass: selectedClass,
            name: characterName,
            levels: levels,
            usedLevels: initialUsedLevels,
            knownSpells: initialKnown,
            preparedSpells: initialPrepared
        )
        modelContext.insert(character)
        
        removeOldFilters()
        addFilters(for: maxLevel, characterId: characterId)
        if maxLevel < 9 {
            addFilters(for: 9, characterId: characterId)
        }

        try? modelContext.save()
        CharacterUpdateService.send()
        isLoading = false
    }
        
    func removeOldCharacters() {
        var fetchDescriptor = FetchDescriptor<CharacterModel>(predicate: #Predicate { model in
            model.id == characterId
        })
        fetchDescriptor.fetchLimit = 1
        let existingCharacters: [CharacterModel] = (try? modelContext.fetch(fetchDescriptor)) ?? []
        for character in existingCharacters {
            modelContext.delete(character)
        }
        try? modelContext.save()
    }

    func removeOldFilters() {
        let text = "\(initialCharacterName) \(selectedClass.name)"

        var fetchDescriptorLevel = FetchDescriptor<Filter>(predicate: #Predicate { filter in
            filter.name.localizedStandardContains(text)
        })
        fetchDescriptorLevel.fetchLimit = 2
        let existingFilters: [Filter] = (try? modelContext.fetch(fetchDescriptorLevel)) ?? []
        for existingFilter in existingFilters {
            modelContext.delete(existingFilter)
        }
        try? modelContext.save()
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
}
