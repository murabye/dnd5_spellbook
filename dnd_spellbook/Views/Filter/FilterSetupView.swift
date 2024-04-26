//
//  FilterView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.12.2023.
//

import SwiftData
import SwiftUI

enum MaterialResctiction: CaseIterable {
    case all
    case noOne
    case maxPrice
    
    var name: String {
        switch self {
        case .all: "Все"
        case .noOne: "Никаких"
        case .maxPrice: "По цене"
        }
    }
}

enum ConcentrationResctiction: CaseIterable {
    case anyway
    case concentration
    case noConcentration
    
    var name: String {
        switch self {
        case .anyway: "Неважно"
        case .concentration: "Обязательно"
        case .noConcentration: "Только без"
        }
    }
}

struct FilterSetupView: View {

    @Binding var character: CharacterModel?

    @AppStorage(UserDefaults.Constants.selectedFilterName) var selectedFilterName: String?
    @State var name: String = ""

    var levels = (Array(0...9) as [Int])
    @State var levelsIsOpened = false
    @State var activeLevels = [0]
    
    @State var materialsResctiction: MaterialResctiction = .all
    @State var materialsMaxPrice: Int?
    
    var sources = Sources.allCases
    @State var sourceIsOpened = false
    @State var activeSources = [Sources.playerHandbook]
    
    var schools = SpellSchool.allCases
    @State var schoolsIsOpened = false
    @State var activeSchools = SpellSchool.allCases
    
    var actions = NoConreteActionType.allCases
    @State var actionsIsOpened = false
    @State var activeActions = NoConreteActionType.allCases
    
    var classes = CharacterClass.allCases
    @State var classesIsOpened = false
    @State var activeClasses = CharacterClass.allCases
    
    @State var concentrationResctiction: ConcentrationResctiction = .anyway
    @State var onlyMute: Bool = false
    @State var onlyNoHands: Bool = false
    @State var bindToCharacter: Bool

    @Query(sort: \Tag.text) var includedTags: [Tag]
    @State var includedTagsIsOpened = false
    @State var activeIncludedTags = [Tag]()
    
    @Query(sort: \Tag.text) var excludedTags: [Tag]
    @State var excludedTagsIsOpened = false
    @State var activeExcludedTags = [Tag]()
    
    @State var showingAlert = false
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            nameSection
            
            levelsSection
            
            concentrationPicker
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            
            materialsPicker
                .padding(.horizontal, 12)
                .padding(.top, 6)
            
            materialsMaxPriceView
                .padding(.horizontal, 12)
            
            sourcesSection
            schoolsSection
            typeOfActionSection
            classesSection
            includedSection
            excludedSection
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.easeIn.speed(2), value: materialsResctiction)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: levelsIsOpened)
        .animation(.easeIn, value: activeLevels)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: sourceIsOpened)
        .animation(.easeIn, value: activeSources)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: schoolsIsOpened)
        .animation(.easeIn, value: activeSchools)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: actionsIsOpened)
        .animation(.easeIn, value: activeActions)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: classesIsOpened)
        .animation(.easeIn, value: activeClasses)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: includedTagsIsOpened)
        .animation(.easeIn.speed(2), value: activeIncludedTags)
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7), value: excludedTagsIsOpened)
        .animation(.easeIn.speed(2), value: activeExcludedTags)
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .navigationTitle("Настройка фильтра")
        .toolbar(content: {
            Button("Сохранить") {
                saveOrAware()
                dismiss()
            }
            .disabled(name.isEmpty)
        })
        .alert("Имя занято", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    var nameSection: some View {
        TextField("Имя фильтра", text: $name)
            .padding(12)
            .background(Color.systemGroupedTableContent)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }

    var levelsSection: some View {
        VStack {
            levelHeader
            levelList
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    var levelHeader: some View {
        HStack {
            Text("Уровни").font(.title2)
            Spacer()
            Image(systemName: "chevron.up")
                .rotationEffect(levelsIsOpened ? .degrees(0) : .degrees(180))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            levelsIsOpened.toggle()
        }
    }
    
    var levelList: some View {
        HStack {
            UniversalTagLine(onDelete: { index in
                guard levelsIsOpened else {
                    activeLevels.remove(at: index)
                    return
                }
                if let index = activeLevels.firstIndex(of: levels[index]) {
                    activeLevels.remove(at: index)
                } else {
                    activeLevels.append(levels[index])
                }
            }, tags: levels
                .filter { levelsIsOpened || activeLevels.contains($0) }
                .map { level in
                    let isActive = activeLevels.contains(level)
                    return UniversalTagProps(
                        title: level.levelName,
                        isActive: isActive,
                        foregroundColor: .white,
                        backgroundColor: .gray,
                        isActionable: true
                    )
                })
            Spacer()
        }
        .clipShape(Rectangle())
    }
    
    var concentrationPicker: some View {
        VStack {
            HStack {
                Text("КОНЦЕНТРАЦИЯ").font(.caption)
                Spacer()
            }
            Picker("Концентрация", selection: $concentrationResctiction) {
                ForEach(ConcentrationResctiction.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var materialsPicker: some View {
        VStack {
            HStack {
                Text("МАТЕРИАЛЫ").font(.caption)
                Spacer()
            }
            Picker("Материалы", selection: $materialsResctiction) {
                ForEach(MaterialResctiction.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var materialsMaxPriceView: some View {
        VStack(spacing: 16) {
            if materialsResctiction == .maxPrice {
                TextField("Максимальная цена ингридиентов", value: $materialsMaxPrice, formatter: NumberFormatter())
            }
            Toggle("Без голоса", isOn: $onlyMute)
            Toggle("Без рук", isOn: $onlyNoHands)
            if character != nil {
                Toggle("Прикрепить к персонажу", isOn: $bindToCharacter)
            }
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var sourcesSection: some View {
        VStack {
            FilterExpandableHeader(
                title: "Источники",
                isOpened: $sourceIsOpened,
                canSelectAll: sources.count != activeSources.count
            ) {
                activeSources = sources
            }
            FilterExpandableContent(
                isOpened: $sourceIsOpened,
                active: $activeSources,
                sources: sources,
                filter: { sourceIsOpened || activeSources.contains($0) }
            )
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 6)
    }
    
    var schoolsSection: some View {
        VStack {
            FilterExpandableHeader(
                title: "Школы",
                isOpened: $schoolsIsOpened,
                canSelectAll: schools.count != activeSchools.count
            ) {
                activeSchools = schools
            }
            if schoolsIsOpened {
                FilterExpandableContent(
                    isOpened: $schoolsIsOpened,
                    active: $activeSchools,
                    sources: schools,
                    filter: { _ in true }
                )
            }
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    var typeOfActionSection: some View {
        VStack {
            FilterExpandableHeader(
                title: "Типы действий",
                isOpened: $actionsIsOpened,
                canSelectAll: actions.count != activeActions.count
            ) {
                activeActions = actions
            }
            FilterExpandableContent(
                isOpened: $actionsIsOpened,
                active: $activeActions,
                sources: actions,
                filter: { actionsIsOpened || activeActions.contains($0) }
            )
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    var classesSection: some View {
        VStack {
            FilterExpandableHeader(
                title: "Классы",
                isOpened: $classesIsOpened,
                canSelectAll: classes.count != activeClasses.count
            ) {
                activeClasses = classes
            }
            if classesIsOpened {
                FilterExpandableContent(
                    isOpened: $classesIsOpened,
                    active: $activeClasses,
                    sources: classes,
                    filter: { _ in true }
                )
            }
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    var includedSection: some View {
        VStack {
            FilterExpandableHeader(
                title: "Обязательные теги",
                isOpened: $includedTagsIsOpened,
                canSelectAll: includedTags.count != activeIncludedTags.count
            ) {
                activeIncludedTags = includedTags
            }
            FilterExpandableTagContent(
                isOpened: $includedTagsIsOpened,
                active: $activeIncludedTags,
                sources: includedTags,
                filter: { includedTagsIsOpened || activeIncludedTags.contains($0) }
            )
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    var excludedSection: some View {
        VStack {
            FilterExpandableHeader(
                title: "Исключенные теги",
                isOpened: $excludedTagsIsOpened,
                canSelectAll: excludedTags.count != activeExcludedTags.count
            ) {
                activeExcludedTags = excludedTags
            }
            FilterExpandableTagContent(
                isOpened: $excludedTagsIsOpened,
                active: $activeExcludedTags,
                sources: excludedTags,
                filter: { excludedTagsIsOpened || activeExcludedTags.contains($0) }
            )
        }
        .padding(12)
        .background(Color.systemGroupedTableContent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    func saveOrAware() {
        if canSave() {
            saveFilter()
            dismiss()
        } else {
            showingAlert = true
        }
    }
    
    func canSave() -> Bool {
        var fetchDescriptor = FetchDescriptor<Filter>(predicate: #Predicate { filter in
            filter.name == name
        })
        fetchDescriptor.fetchLimit = 1

        do {
            let filters = try modelContext.fetch(fetchDescriptor)
            return filters.isEmpty
        } catch {
            return false
        }
    }

    func saveFilter() {
        let filter = Filter(
            name: name,
            levels: activeLevels,
            noMaterials: materialsResctiction == .noOne,
            maxMaterialPriceInGold: materialsResctiction == .maxPrice ? materialsMaxPrice : nil,
            sources: activeSources,
            schools: activeSchools,
            actions: activeActions,
            concentration: concentrationResctiction == .concentration
            ? true
            : concentrationResctiction == .noConcentration
            ? false
            : nil,
            included: activeIncludedTags,
            excluded: activeExcludedTags,
            classes: activeClasses,
            onlyMute: onlyMute,
            onlyNoHands: onlyNoHands,
            character: bindToCharacter ? character : nil
        )
        modelContext.insert(filter)
        try? modelContext.save()
        selectedFilterName = name
    }
}

