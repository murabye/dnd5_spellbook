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
    
    let safeArea: EdgeInsets

    @State private var selectedImage: UIImage? = nil
    @State private var characterName: String = ""
    @State private var selectedClass: CharacterClass = .nothing

    @State private var selectedBardCollegy: BardCollegy = .defaultValue
    @State private var selectedWizardSchool: WizardSchool = .defaultValue
    @State private var selectedDruidCircle: DruidCircle = .defaultValue
    @State private var selectedClericDomain: ClericDomain = .defaultValue
    @State private var selectedArtificerSpeciality: ArtificerSpeciality = .defaultValue
    @State private var selectedWarlockPatron: WarlockPatron = .defaultValue
    @State private var selectedPaladinOath: PaladinOath = .defaultValue
    @State private var selectedRangerArchetype: RangerArchetype = .defaultValue
    @State private var selectedSorcererOrigin: SorcererOrigin = .defaultValue
    
    @State private var isPickerSelected = false
    @State private var scrollOffset: CGFloat = 0.0
    @State private var autoknowedSpells = [Spell]()
    @State private var paginationOffset: Int = 0

    var subclassed: CharacterArchetype {
        switch selectedClass {
        case .bard: .bard(selectedBardCollegy)
        case .wizard: .wizard(selectedWizardSchool)
        case .druid: .druid(selectedDruidCircle)
        case .cleric: .cleric(selectedClericDomain)
        case .artificer: .artificer(selectedArtificerSpeciality)
        case .warlock: .warlock(selectedWarlockPatron)
        case .paladin: .paladin(selectedPaladinOath)
        case .ranger: .ranger(selectedRangerArchetype)
        case .sorcerer: .sorcerer(selectedSorcererOrigin)
        case .nothing: .nothing
        }
    }
    
    var archetype: any Archetype {
        switch subclassed {
        case let .bard(subtype): subtype
        case let .wizard(subtype): subtype
        case let .druid(subtype): subtype
        case let .cleric(subtype): subtype
        case let .artificer(subtype): subtype
        case let .warlock(subtype): subtype
        case let .paladin(subtype): subtype
        case let .ranger(subtype): subtype
        case let .sorcerer(subtype): subtype
        case .nothing: NoneSubclass.nothing
        }
    }
    
    var body: some View {
        ZStack {
            ObservableScrollView(scrollOffset: $scrollOffset) { _ in
                imagePickerView
                VStack {
                    TextField("Имя", text: $characterName)
                        .padding(.bottom, 6)
                        .padding(.top, 3)
                    Divider()
                    classPicker
                    if selectedClass != .nothing {
                        Divider()
                        archetypePicker
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.systemGroupedTableContent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                if !autoknowedSpells.isEmpty {
                    autoSpellsHeader.padding(.horizontal)
                    autoSpellsList.padding(.horizontal)
                }
                
                LazyVStack {
                    Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadSpells() }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    applyButton
                    cancelButton
                }
                Spacer()
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
        .onChange(of: selectedClass, { _, _ in
            autoknowedSpells = []
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
    
    var archetypePicker: some View {
        Group {
            switch selectedClass {
            case .bard:
                CharacterClassCreationPicker(
                    selected: $selectedBardCollegy,
                    allCases: BardCollegy.allCases,
                    isCompact: true
                )
            case .wizard:
                CharacterClassCreationPicker(
                    selected: $selectedWizardSchool,
                    allCases: WizardSchool.allCases,
                    isCompact: true
                )
            case .druid:
                CharacterClassCreationPicker(
                    selected: $selectedDruidCircle,
                    allCases: DruidCircle.allCases,
                    isCompact: true
                )
            case .cleric:
                CharacterClassCreationPicker(
                    selected: $selectedClericDomain,
                    allCases: ClericDomain.allCases,
                    isCompact: true
                )
            case .artificer:
                CharacterClassCreationPicker(
                    selected: $selectedArtificerSpeciality,
                    allCases: ArtificerSpeciality.allCases,
                    isCompact: true
                )
            case .warlock:
                CharacterClassCreationPicker(
                    selected: $selectedWarlockPatron,
                    allCases: WarlockPatron.allCases,
                    isCompact: true
                )
            case .paladin:
                CharacterClassCreationPicker(
                    selected: $selectedPaladinOath,
                    allCases: PaladinOath.allCases,
                    isCompact: true
                )
            case .ranger:
                CharacterClassCreationPicker(
                    selected: $selectedRangerArchetype,
                    allCases: RangerArchetype.allCases,
                    isCompact: true
                )
            case .sorcerer:
                CharacterClassCreationPicker(
                    selected: $selectedSorcererOrigin,
                    allCases: SorcererOrigin.allCases,
                    isCompact: true
                )
            case .nothing:
                CharacterClassCreationPicker(
                    selected: $selectedSorcererOrigin,
                    allCases: SorcererOrigin.allCases,
                    isCompact: true
                )
            }
        }
    }
    
    var autoSpellsHeader: some View {
        HStack {
            Text("Известные автоматически")
            Spacer()
            Button("Забыть все", action: { self.autoknowedSpells = [] })
        }
    }
    
    var autoSpellsList: some View {
        LazyVStack {
            ForEach(
                autoknowedSpells,
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
                           let index = autoknowedSpells.firstIndex(of: spell) {
                            autoknowedSpells.remove(at: index)
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
        let imageUrl = FileManager.default.save(image: selectedImage)
        let newCharacterId = UUID().uuidString
        UserDefaults.standard.selectedId = newCharacterId
        let character = CharacterModel(
            id: newCharacterId,
            imageUrl: imageUrl,
            characterSubclass: subclassed,
            name: characterName,
            tagActions: [:],
            knownSpells: autoknowedSpells,
            preparedSpells: []
        )
        modelContext.insert(character)
        try? modelContext.save()
        CharacterUpdateService.send()
    }
    
    
    func loadSpells() {
        guard selectedClass == .cleric || selectedClass == .druid else {
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
            autoknowedSpells.append(contentsOf: newData.filter { $0.classes.contains(selectedClass) })
        }
    }
}
