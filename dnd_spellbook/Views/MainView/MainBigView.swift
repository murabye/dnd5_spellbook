//
//  ContentView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

enum NavWay: Int, Hashable {
    
    case search
    case characterList
    case authorPage
    case filterCreate
    case hiddenSpells
}

struct MainBigView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var navPath = NavigationPath()

    let columnAmount: Int
    
    @State var isSpellLevelRule: Bool = false
    @State var isSpellCreationOpened: Bool = false
    
    @State var scrollOffset: CGPoint = .zero

    // filters
    @Query(sort: \Filter.name) var filters: [Filter] = []
    @AppStorage(UserDefaults.Constants.selectedFilterName) var selectedFilterName: String?
    var selectedFilter: Filter? {
        filters.first { $0.name == selectedFilterName }
    }
    
    // additional content
    @AppStorage(UserDefaults.Constants.selectedId) var selectedCharacterId: String?
    @Query(sort: \CharacterModel.name) var characters: [CharacterModel]
    @State var character: CharacterModel? = nil
    @Query var materials: [MaterialModel]
    @Query var tags: [Tag]
    
    // spells
    @State var preparedSpellsMap: [String: Bool] = [:]
    @State var knownSpellsMap: [String: Bool] = [:]
    @State var characterPrepared = [Int: [Spell]]()
    @State var characterKnown = [Int: [Spell]]()
    @State var other = [Int: [Spell]]()
    @State var fetchedOther: [Spell] = []

    @State var otherBatchIsEmpty: Bool = false
    @State var isLoading: Bool = false
    
    @State var isOtherHidden: Bool = true

  private var filterModels: [FilterModel] {
    var array = filters
      .filter { $0.character.isEmpty || $0.character == character?.id }
      .map { FilterModel(.fiter($0)) }
    array.insert(FilterModel(.reset), at: 0)
    array.insert(FilterModel(.plus), at: 0)
    return array
  }

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollViewReader { scrollProxy in
                ZStack {
                    ScrollView {
                        SectionIndexTitleView(name: .prepared, isHidden: .constant(false), scrollOffset: $scrollOffset)
                        if !characterPrepared.isEmpty {
                            VerticalWaterfallLayout(
                                columns: columnAmount,
                                spacingX: 16,
                                spacingY: 16
                            ) {
                                SpellListView(
                                    spellsByLevel: $characterPrepared,
                                    character: $character,
                                    preparedSpellsMap: .constant([:]),
                                    knownSpellsMap: .constant([:]),
                                    pinIndex: 1,
                                    name: .prepared,
                                    onHide: { spell in onHide(spell) },
                                    onUnhide: { _ in },
                                    onRemove: { spell in onRemove(spell) },
                                    onKnow: { spell in onKnow(spell) },
                                    onUnknow: { spell in onUnknow(spell) },
                                    onPrepare: { spell in onPrepare(spell) },
                                    onUnprepare: { spell in onUnprepare(spell) }
                                )
                            }
                            .padding()
                        }
                        
                        SectionIndexTitleView(name: .known, isHidden: .constant(false), scrollOffset: $scrollOffset)
                        if !characterKnown.isEmpty {
                            VerticalWaterfallLayout(
                                columns: columnAmount,
                                spacingX: 16,
                                spacingY: 16
                            ) {
                                SpellListView(
                                    spellsByLevel: $characterPrepared,
                                    character: $character,
                                    preparedSpellsMap: .constant([:]),
                                    knownSpellsMap: .constant([:]),
                                    pinIndex: 1,
                                    name: .known,
                                    onHide: { spell in onHide(spell) },
                                    onUnhide: { _ in },
                                    onRemove: { spell in onRemove(spell) },
                                    onKnow: { spell in onKnow(spell) },
                                    onUnknow: { spell in onUnknow(spell) },
                                    onPrepare: { spell in onPrepare(spell) },
                                    onUnprepare: { spell in onUnprepare(spell) }
                                )
                            }
                            .padding()
                        }
                        
                        NavigationLink(value: NavWay.hiddenSpells) {
                            SectionIndexTitleView(name: .hidden, isHidden: .constant(false), scrollOffset: $scrollOffset)
                        }
                        .padding(.bottom)
                        
                        SectionIndexTitleView(name: .other, isHidden: $isOtherHidden, scrollOffset: $scrollOffset)
                        if !isOtherHidden {
                            VerticalWaterfallLayout(
                                columns: columnAmount,
                                spacingX: 16,
                                spacingY: 16
                            ) {
                                SpellListView(
                                    spellsByLevel: $characterPrepared,
                                    character: $character,
                                    preparedSpellsMap: .constant([:]),
                                    knownSpellsMap: .constant([:]),
                                    pinIndex: 1,
                                    name: .other,
                                    onHide: { spell in onHide(spell) },
                                    onUnhide: { _ in },
                                    onRemove: { spell in onRemove(spell) },
                                    onKnow: { spell in onKnow(spell) },
                                    onUnknow: { spell in onUnknow(spell) },
                                    onPrepare: { spell in onPrepare(spell) },
                                    onUnprepare: { spell in onUnprepare(spell) }
                                )
                            }
                            .padding()
                            LazyVStack {
                                Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadOther() }
                            }
                            if otherBatchIsEmpty {
                                HStack {
                                    Spacer()
                                    Button("Загрузить еще...") { loadOther() }
                                        .buttonStyle(.borderedProminent)
                                    Spacer()
                                }
                            }
                            Spacer().frame(height: 60)
                        }
                    }
                    .pinContainer()

                    sectionIndexTitles(proxy: scrollProxy)

                  MainViewFilterLayer(
                    filterModels: filterModels,
                    selectedFilter: selectedFilter,
                    selectedFilterName: $selectedFilterName,
                    navPath: $navPath,
                    removeFilter: remove(filter:)
                  )
                }
            }
            .background(
                Color(uiColor: UIColor.systemGroupedBackground)
            )
            .navigationBarTitle("Заклинания", displayMode: .inline)
            .toolbar {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    }
                    
                    if character != nil {
                        Button {
                            isSpellLevelRule.toggle()
                        } label: {
                            Image(systemName: "hand.point.up.braille")
                                .font(.title2)
                        }
                        .popover(isPresented: $isSpellLevelRule, content: {
                            SpellCellsRestoreView(character: $character)
                        })
                    }
                    
                    Button {
                        isSpellCreationOpened.toggle()
                    } label: {
                        Image(systemName: "plus").font(.title2)
                    }
                    
                    NavigationLink(value: NavWay.search) {
                        Image(systemName: "magnifyingglass").font(.title2)
                    }
                    
                    NavigationLink(value: NavWay.characterList) {
                        CharacterListItem(
                            character: character,
                            isCompact: true
                        )
                    }
                    .contextMenu {
                        ForEach(characters, id: \.id) { character in
                            Button(character.name) { [weak character] in
                                guard let character else { return }
                                UserDefaults.standard.selectedId = character.id
                                CharacterUpdateService.send()
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: NavWay.self) { navWay in
                switch navWay {
                case .characterList: CharacterList()
                case .authorPage: AuthorPage()
                case .filterCreate: FilterSetupBigView(character: $character, bindToCharacter: character != nil)
                case .search:
                    SearchBigView(
                        columnAmount: columnAmount,
                        character: $character,
                        preparedSpellsMap: $preparedSpellsMap,
                        knownSpellsMap: $knownSpellsMap
                    )
                case .hiddenSpells:
                    HiddenSpellsBigView(
                        columnAmount: columnAmount,
                        allMaterials: materials,
                        allTags: tags,
                        character: $character
                    )
                }
            }
            .sheet(isPresented: $isSpellCreationOpened) {
                SpellCreationView()
            }
            .appearOnce {
                recallCharacter()
            }
            .onReceive(CharacterUpdateService.publisher()) { _ in
                recallCharacter()
            }
            .onChange(of: selectedCharacterId) { _ in
                selectedFilterName = ""
            }
            .onChange(of: selectedFilter) { old, new in
                guard old != new else { return }
                restartLoading()
            }
        }
    }

    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: [.prepared, .known, .hidden, .other])
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }

    // MARK: - filters
    private func remove(filter: Filter?) {
        guard let filter else { return }
        if selectedFilterName == filter.name {
            selectedFilterName = ""
        }
        modelContext.delete(filter)
        try? modelContext.save()
    }
    
    // MARK: - spell loading
    func recallCharacter() {
        guard let userId = UserDefaults.standard.selectedId, !userId.isEmpty else {
            restartLoading()
            return
        }
        
        var fetchDescriptor = FetchDescriptor<CharacterModel>(predicate: #Predicate { character in
            character.id == userId
        })
        fetchDescriptor.fetchLimit = 1
        character = (try? modelContext.fetch(fetchDescriptor))?.first
        restartLoading()
    }
    
    func restartLoading() {
        characterKnown = [:]
        characterPrepared = [:]
        other = [:]
        fetchedOther = []
        knownSpellsMap = [:]
        preparedSpellsMap = [:]
        otherBatchIsEmpty = false
        isLoading = true
        loadPrepared {
            loadKnown {
                loadOther()
                isLoading = false
            }
        }
    }
    
    func loadPrepared(onFinish: @escaping () -> ()) {
        guard let character else {
            characterPrepared = [:]
            preparedSpellsMap = [:]
            onFinish()
            return
        }
        
        Task.detached {
            let allPreparedSpells = character.preparedSpells
            guard let selectedFilter else {
                characterPrepared = Dictionary(grouping: allPreparedSpells, by: \.level)
                allPreparedSpells
                    .map(\.id)
                    .forEach { id in
                        preparedSpellsMap[id] = true
                    }
                Task.detached { @MainActor in
                    onFinish()
                }
                return
            }
            
            let result = selectedFilter.satisfying(
                spells: allPreparedSpells.sorted(by: { $0.level < $1.level }),
                allMaterials: materials,
                allTags: tags
            )
            characterPrepared = Dictionary(grouping: result, by: \.level)
            allPreparedSpells
                .map(\.id)
                .forEach { id in
                    preparedSpellsMap[id] = true
                }
            Task.detached { @MainActor in
                onFinish()
            }
        }
    }
    
    func loadKnown(onFinish: @escaping () -> ()) {
        guard let character else {
            characterKnown = [:]
            knownSpellsMap = [:]
            onFinish()
            return
        }
        
        Task.detached {
            let allKnownSpells = character.knownSpells
            guard let selectedFilter else {
                characterKnown =  Dictionary(grouping: allKnownSpells, by: \.level)
                allKnownSpells
                    .map(\.id)
                    .forEach { id in
                        knownSpellsMap[id] = true
                    }
                Task.detached { @MainActor in
                    onFinish()
                }
                return
            }
            
            let result = selectedFilter.satisfying(
                spells: allKnownSpells,
                allMaterials: materials,
                allTags: tags
            )
            characterKnown = Dictionary(grouping: result, by: \.level)
            allKnownSpells
                .map(\.id)
                .forEach { id in
                    knownSpellsMap[id] = true
                }
            Task.detached { @MainActor in
                onFinish()
            }
        }
    }
    
    @State var counter = 0
    func loadOther() {
        counter +=  1
        guard !isOtherHidden else {
            return
        }
        isLoading = true
        otherBatchIsEmpty = false
        var fetchDescriptor = FetchDescriptor<Spell>(
            predicate: #Predicate { spell in
                spell.isHidden == false
            },
            sortBy: [SortDescriptor(\.id)]
        )
        guard let totalAmount = try? modelContext.fetchCount(fetchDescriptor) else {
            otherBatchIsEmpty = true
            isLoading = false
            return
        }
        
        fetchDescriptor.fetchLimit = 30
        fetchDescriptor.fetchOffset = min(totalAmount, fetchedOther.count)
        
        if totalAmount > fetchedOther.count {
            let newData = (try? modelContext.fetch(fetchDescriptor)) ?? []
            
            let filtered = selectedFilter?.satisfying(
                spells: newData,
                allMaterials: materials,
                allTags: tags
            ) ?? newData
            
            let cleanPrepared = filtered
                .filter { preparedSpellsMap[$0.id] != true && knownSpellsMap[$0.id] != true }
            
            fetchedOther.append(contentsOf: newData)
            for spell in cleanPrepared {
                other.appendOrSet(spell)
            }
            otherBatchIsEmpty = cleanPrepared.isEmpty
            isLoading = false
        } else {
            otherBatchIsEmpty = false
            isLoading = false
        }
    }
    
    // MARK: - actions
    func onHide(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let otherIndex = other[spell.level]?.firstIndex(of: spell)
            let fetchedOtherIndex = fetchedOther.firstIndex(of: spell)

            Task.detached { @MainActor in
                if let otherIndex { other[spell.level]?.remove(at: otherIndex) }
                if let fetchedOtherIndex { fetchedOther.remove(at: fetchedOtherIndex) }
                isLoading = false
            }
        }
    }
    
    func onUnknow(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let characterKnownIndex = characterKnown[spell.level]?.firstIndex(of: spell)
            let otherContains = other[spell.level]?.contains(spell) == true

            Task.detached { @MainActor in
                if let characterKnownIndex {
                    characterKnown[spell.level]?.remove(at: characterKnownIndex)
                    knownSpellsMap[spell.id] = false
                }
                if otherContains { other.appendOrSet(spell) }
                isLoading = false
            }
        }
    }
    
    func onRemove(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let characterPreparedIndex = characterPrepared[spell.level]?.firstIndex(of: spell)
            let characterKnownIndex = characterKnown[spell.level]?.firstIndex(of: spell)
            let otherIndex = other[spell.level]?.firstIndex(of: spell)
            let fetchedOtherIndex = fetchedOther.firstIndex(of: spell)
            
            Task.detached { @MainActor in
                if let characterPreparedIndex {
                    characterPrepared[spell.level]?.remove(at: characterPreparedIndex)
                    preparedSpellsMap[spell.id] = false
                }
                if let characterKnownIndex {
                    characterKnown[spell.level]?.remove(at: characterKnownIndex)
                    knownSpellsMap[spell.id] = false
                }
                if let otherIndex { other[spell.level]?.remove(at: otherIndex) }
                if let fetchedOtherIndex { fetchedOther.remove(at: fetchedOtherIndex) }
                isLoading = false
            }
        }
    }
    
    func onKnow(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let otherIndex = other[spell.level]?.firstIndex(of: spell)
            let characterKnownContains = characterKnown[spell.level]?.contains(spell) == true
            
            Task.detached { @MainActor in
                if let otherIndex { other[spell.level]?.remove(at: otherIndex) }
                if !characterKnownContains {
                    characterKnown.appendOrSet(spell)
                    knownSpellsMap[spell.id] = true
                }
                isLoading = false
            }
        }
        
    }
    
    func onPrepare(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let index = characterKnown[spell.level]?.firstIndex(of: spell)
            let contains = characterPrepared[spell.level]?.contains(spell) == true
            
            Task.detached { @MainActor in
                if let index {
                    characterKnown[spell.level]?.remove(at: index)
                    knownSpellsMap[spell.id] = false
                }
                
                if !contains {
                    characterPrepared.appendOrSet(spell)
                    preparedSpellsMap[spell.id] = true
                }
                isLoading = false
            }
        }
    }
    
    func onUnprepare(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let index = characterPrepared[spell.level]?.firstIndex(of: spell)
            let contains = characterKnown[spell.level]?.contains(spell) == true
            
            Task.detached { @MainActor in
                if let index {
                    characterPrepared[spell.level]?.remove(at: index)
                    preparedSpellsMap[spell.id] = false
                }
                
                if !contains {
                    characterKnown.appendOrSet(spell)
                    knownSpellsMap[spell.id] = true
                }
                isLoading = false
            }
        }
    }
}
