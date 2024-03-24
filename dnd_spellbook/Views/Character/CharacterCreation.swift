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
        GeometryReader { proxy in
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
                
                applyButton
                cancelButton
            }
            .animation(.easeIn, value: selectedClass)
            .sheet(isPresented: $isPickerSelected) {
                UIPickerView(image: $selectedImage)
                    .ignoresSafeArea()
            }
            .mergingDynamicIslandWithView(
                forKey: Constants.islandCollapsableItemKey,
                safeArea: proxy.safeAreaInsets,
                backgroundColor: Color(uiColor: .systemGroupedBackground)
            )
        }
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
    
    var applyButton: some View {
        Button(action: {
            addCharacter()
            dismiss()
        }, label: {
            HStack {
                Spacer()
                Text("Готово")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(8)
                Spacer()
            }
        })
        .buttonStyle(.borderedProminent)
        .disabled(characterName.isEmpty)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    var cancelButton: some View {
        Button(action: {
            dismiss()
        }, label: {
            HStack {
                Spacer()
                Text("Отмена")
                    .font(.headline)
                    .padding(8)
                Spacer()
            }
        })
        .buttonStyle(.borderless)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    func addCharacter() {
        let imageUrl = FileManager.default.save(image: selectedImage)
        let newCharacterId = UUID().uuidString
        UserDefaults.standard.selectedId = newCharacterId
        let character = Character(
            id: newCharacterId,
            imageUrl: imageUrl,
            characterSubclass: subclassed,
            name: characterName,
            tagActions: [:],
            knownSpells: [],
            preparedSpells: []
        )
        modelContext.insert(character)
        try? modelContext.save()
    }
}
