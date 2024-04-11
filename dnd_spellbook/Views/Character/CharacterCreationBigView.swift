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

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

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

    @State var autoknowedSpells = [Spell]()
    @State var paginationOffset: Int = 0
    
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
        case let .bard(subtype): return subtype
        case let .wizard(subtype): return subtype
        case let .druid(subtype): return subtype
        case let .cleric(subtype): return subtype
        case let .artificer(subtype): return subtype
        case let .warlock(subtype): return subtype
        case let .paladin(subtype): return subtype
        case let .ranger(subtype): return subtype
        case let .sorcerer(subtype): return subtype
        case .nothing: return NoneSubclass.nothing
        }
    }
    
    var body: some View {
        ScrollView {
            VerticalWaterfallLayout(
                columns: columnAmount,
                spacingX: 16,
                spacingY: 16
            ) {
                imagePickerView
                classPicker
                archetypePicker
            }
            .padding()
            
            if !autoknowedSpells.isEmpty {
                autoSpellsHeader.padding(.horizontal)
                autoknowedSpellsList.padding(.horizontal)
            }
            
            LazyVStack {
                Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadSpells() }
            }
        }
        .sheet(isPresented: $isPickerSelected) {
            UIPickerView(image: $selectedImage).ignoresSafeArea()
        }
        .toolbar {
            applyButton
            cancelButton
        }
        .onChange(of: selectedClass, { _, _ in
            autoknowedSpells = []
            paginationOffset = 0
            loadSpells()
        })
        .background(Color(uiColor: .systemGroupedBackground))
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
                        Image("plus")
                            .resizable()
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
    
    var archetypePicker: some View {
        Group {
            switch selectedClass {
            case .bard:
                CharacterClassCreationPicker(
                    selected: $selectedBardCollegy,
                    allCases: BardCollegy.allCases,
                    isCompact: false
                )
            case .wizard:
                CharacterClassCreationPicker(
                    selected: $selectedWizardSchool,
                    allCases: WizardSchool.allCases,
                    isCompact: false
                )
            case .druid:
                CharacterClassCreationPicker(
                    selected: $selectedDruidCircle,
                    allCases: DruidCircle.allCases,
                    isCompact: false
                )
            case .cleric:
                CharacterClassCreationPicker(
                    selected: $selectedClericDomain,
                    allCases: ClericDomain.allCases,
                    isCompact: false
                )
            case .artificer:
                CharacterClassCreationPicker(
                    selected: $selectedArtificerSpeciality,
                    allCases: ArtificerSpeciality.allCases,
                    isCompact: false
                )
            case .warlock:
                CharacterClassCreationPicker(
                    selected: $selectedWarlockPatron,
                    allCases: WarlockPatron.allCases,
                    isCompact: false
                )
            case .paladin:
                CharacterClassCreationPicker(
                    selected: $selectedPaladinOath,
                    allCases: PaladinOath.allCases,
                    isCompact: false
                )
            case .ranger:
                CharacterClassCreationPicker(
                    selected: $selectedRangerArchetype,
                    allCases: RangerArchetype.allCases,
                    isCompact: false
                )
            case .sorcerer:
                CharacterClassCreationPicker(
                    selected: $selectedSorcererOrigin,
                    allCases: SorcererOrigin.allCases,
                    isCompact: false
                )
            case .nothing: Text("")
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
    
    var autoknowedSpellsList: some View {
        VerticalWaterfallLayout(
            columns: columnAmount,
            spacingX: 16,
            spacingY: 16
        ) {
            ForEach(autoknowedSpells, id: \.id) { spell in
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
}
