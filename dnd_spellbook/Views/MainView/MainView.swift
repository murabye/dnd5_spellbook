//
//  ContentView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

struct MainView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var navPath = NavigationPath()
    
    @State var isSpellCreationOpened: Bool = false
    @State var isSpellLevelRule: Bool = false

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
    @State var characterPrepared = [Spell]()
    @State var characterKnown = [Spell]()
    @State var other = [Spell]()
    @State var fetchedOther = [Spell]()
    
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
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            SectionIndexTitleView(name: .prepared, canHide: false, isHidden: .constant(false))
                            if !characterPrepared.isEmpty {
                                SpellListView(
                                    spells: $characterPrepared,
                                    character: $character,
                                    name: .prepared,
                                    onHide: { spell in onHide(spell) },
                                    onUnhide: { _ in },
                                    onRemove: { spell in onRemove(spell) },
                                    onKnow: { spell in onKnow(spell) },
                                    onUnknow: { spell in onUnknow(spell) },
                                    onPrepare: { spell in onPrepare(spell) },
                                    onUnprepare: { spell in onUnprepare(spell) }
                                )
                                .padding()
                            }
                            
                            SectionIndexTitleView(name: .known, canHide: false, isHidden: .constant(false))
                            if !characterKnown.isEmpty {
                                SpellListView(
                                    spells: $characterKnown,
                                    character: $character,
                                    name: .known,
                                    onHide: { spell in onHide(spell) },
                                    onUnhide: { _ in },
                                    onRemove: { spell in onRemove(spell) },
                                    onKnow: { spell in onKnow(spell) },
                                    onUnknow: { spell in onUnknow(spell) },
                                    onPrepare: { spell in onPrepare(spell) },
                                    onUnprepare: { spell in onUnprepare(spell) }
                                )
                                .padding()
                            }
                            
                            NavigationLink(value: NavWay.hiddenSpells) {
                                SectionIndexTitleView(
                                    name: .hidden,
                                    canHide: false,
                                    isHidden: .constant(false)
                                )
                            }
                            .padding(.bottom)
                            
                            SectionIndexTitleView(name: .other, canHide: true, isHidden: $isOtherHidden)
                            Group {
                                if !isOtherHidden {
                                    SpellListView(
                                        spells: $other,
                                        character: $character,
                                        name: .other,
                                        onHide: { spell in onHide(spell) },
                                        onUnhide: { _ in },
                                        onRemove: { spell in onRemove(spell) },
                                        onKnow: { spell in onKnow(spell) },
                                        onUnknow: { spell in onUnknow(spell) },
                                        onPrepare: { spell in onPrepare(spell) },
                                        onUnprepare: { spell in onUnprepare(spell) }
                                    )
                                    .padding()
                                    
                                    Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadOther() }
                                    if otherBatchIsEmpty {
                                        HStack {
                                            Spacer()
                                            Button("Загрузить еще...") { loadOther() }
                                                .buttonStyle(.borderedProminent)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
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
            .navigationBarTitle("Заклинания")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isSpellCreationOpened.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
                
                if character != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isSpellLevelRule.toggle()
                        } label: {
                            Image(systemName: "hand.point.up.braille")
                                .font(.title2)
                        }
                        .popover(isPresented: $isSpellLevelRule) {
                            SpellCellsRestoreView(character: $character)
                        }
                    }
                }
                
                if isLoading {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: NavWay.search) {
                        Image(systemName: "magnifyingglass").font(.title2)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
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
                case .filterCreate: FilterSetupView(character: $character, bindToCharacter: character != nil)
                case .search: SearchView(character: $character)
                case .hiddenSpells:
                    HiddenSpellsView(
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
        characterKnown = []
        characterPrepared = []
        other = []
        fetchedOther = []
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
            characterPrepared = []
            onFinish() 
            return
        }
        
        Task.detached {
            let allPreparedSpells = character.preparedSpells
            guard let selectedFilter else {
                characterPrepared = allPreparedSpells.sorted(by: { $0.level < $1.level })
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
            characterPrepared = result
            Task.detached { @MainActor in
                onFinish()
            }
        }
    }
    
    func loadKnown(onFinish: @escaping () -> ()) {
        guard let character else {
            characterKnown = []
            onFinish()
            return
        }
        
        Task.detached {
            let allKnownSpells = character.knownSpells
            guard let selectedFilter else {
                characterKnown = allKnownSpells.sorted(by: { $0.level < $1.level })
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
            characterKnown = result.sorted(by: { $0.level < $1.level })
            Task.detached { @MainActor in
                onFinish()
            }
        }
    }
    
    func loadOther() {
        guard !isOtherHidden else { return }
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
                .subtracting(characterPrepared)
                .subtracting(characterKnown)
            
            fetchedOther.append(contentsOf: newData)
            other.append(contentsOf: cleanPrepared)
            otherBatchIsEmpty = cleanPrepared.isEmpty
            isLoading = false
        } else {
            otherBatchIsEmpty = false
            isLoading = false
        }
    }
    
    // MARK: actions
    func onHide(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let otherIndex = other.firstIndex(of: spell)
            let fetchedOtherIndex = fetchedOther.firstIndex(of: spell)
            
            Task.detached { @MainActor in
                if let otherIndex { other.remove(at: otherIndex) }
                if let fetchedOtherIndex { fetchedOther.remove(at: fetchedOtherIndex) }
                isLoading = false
            }
        }
    }
    
    func onUnknow(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let characterKnownIndex = characterKnown.firstIndex(of: spell)
            let fetchedOtherContains = fetchedOther.contains(spell)
            
            Task.detached { @MainActor in
                if let characterKnownIndex { characterKnown.remove(at: characterKnownIndex) }
                if fetchedOtherContains { other.append(spell) }
                isLoading = false
            }
        }
    }
    
    func onRemove(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let characterPreparedIndex = characterPrepared.firstIndex(of: spell)
            let characterKnownIndex = characterKnown.firstIndex(of: spell)
            let otherIndex = other.firstIndex(of: spell)
            let fetchedOtherIndex = fetchedOther.firstIndex(of: spell)
            
            Task.detached { @MainActor in
                if let characterPreparedIndex { characterPrepared.remove(at: characterPreparedIndex) }
                if let characterKnownIndex { characterKnown.remove(at: characterKnownIndex) }
                if let otherIndex { other.remove(at: otherIndex) }
                if let fetchedOtherIndex { fetchedOther.remove(at: fetchedOtherIndex) }
                isLoading = false
            }
        }
    }
    
    func onKnow(_ spell: Spell) {
        isLoading = true
        
        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let otherIndex = other.firstIndex(of: spell)
            let characterKnownContains = characterKnown.contains(spell)
            
            Task.detached { @MainActor in
                if let otherIndex { other.remove(at: otherIndex) }
                if !characterKnownContains { characterKnown.append(spell) }
                isLoading = false
            }
        }
        
    }
    
    func onPrepare(_ spell: Spell) {
        isLoading = true

        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let index = characterKnown.firstIndex(of: spell)
            let contains = characterPrepared.contains(spell)
            
            Task.detached { @MainActor in
                if let index {
                    characterKnown.remove(at: index)
                }
                
                if !contains {
                    characterPrepared.append(spell)
                }
                isLoading = false
            }
        }
    }
    
    func onUnprepare(_ spell: Spell) {
        isLoading = true

        Task.detached {
            try? await Task.sleep(nanoseconds: 500000000)
            let index = characterPrepared.firstIndex(of: spell)
            let contains = characterKnown.contains(spell)
            
            Task.detached { @MainActor in
                if let index {
                    characterPrepared.remove(at: index)
                }
                
                if !contains {
                    characterKnown.append(spell)
                }
                isLoading = false
            }
        }

    }
}
