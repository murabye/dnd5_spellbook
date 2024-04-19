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
    
    @State var isSpellCreationOpened: Bool = false
    
    // filters
    @Query(sort: \Filter.name) var filters: [Filter] = []
    @AppStorage(UserDefaults.Constants.selectedFilterName) var selectedFilterName: String?
    var selectedFilter: Filter? {
        filters.first { $0.name == selectedFilterName }
    }
    
    // additional content
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
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ZStack {
                    ScrollView {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            Section {
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
                            } header: {
                                SectionIndexTitleView(name: .prepared, canHide: false, isHidden: .constant(false))
                            }
                            
                            Section {
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
                            } header: {
                                SectionIndexTitleView(name: .known, canHide: false, isHidden: .constant(false))
                            }
                            
                            NavigationLink(value: NavWay.hiddenSpells) {
                                SectionIndexTitleView(name: .hidden, canHide: false, isHidden: .constant(false))
                            }
                            .padding(.bottom)
                                                        
                            Section {
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
                            } header: {
                                SectionIndexTitleView(name: .other, canHide: true, isHidden: $isOtherHidden)
                            }
                            
                            Spacer(minLength: 16)
                        }
                    }
                    
                    sectionIndexTitles(proxy: scrollProxy)
                }
            }
            
            toolbar
        }
        .background(
            Color(uiColor: UIColor.systemGroupedBackground)
        )
        .navigationBarTitle("Заклинания")
        .toolbar(content: {
            HStack {
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                }
                
                NavigationLink(value: NavWay.search) {
                    Image(systemName: "magnifyingglass").font(.title2)
                }

                Button {
                    isSpellCreationOpened.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
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
        })
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
        .onReceive(UserDefaults.standard.selectedId.publisher) { _ in
            let filtered = filters
                .filter { $0.character.isEmpty || $0.character == UserDefaults.standard.selectedId }
            selectedFilterName = filtered.first?.id ?? ""
        }
        .onChange(of: selectedFilter, { old, new in
            guard old != new else { return }
            restartLoading()
        })
    }
    
    var toolbar: some View {
        ScrollView(.horizontal) {
            Divider()
            HStack {
                Spacer(minLength: 16)
                NavigationLink(value: NavWay.filterCreate) {
                    Image(systemName: "text.badge.plus")
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedFilter == nil ? .blue : .gray)
                        .clipShape(Capsule())
                }
                
                UniversalTagView(
                    tagProps: UniversalTagProps(
                        title: "Без фильтра",
                        isActive: selectedFilterName == nil || selectedFilterName == "",
                        foregroundColor: .white,
                        backgroundColor: selectedFilterName == nil || selectedFilterName == "" ? .blue : .gray,
                        isActionable: false
                    )
                )
                .onTapGesture {
                    selectedFilterName = nil
                }

                ForEach(filters.filter { $0.character.isEmpty || $0.character == character?.id }, id: \.name) { filter in
                    UniversalTagView(
                        tagProps: UniversalTagProps(
                            title: filter.name,
                            isActive: filter.name == selectedFilterName,
                            foregroundColor: .white,
                            backgroundColor: filter.name == selectedFilterName ? .blue : .gray,
                            isActionable: false
                        )
                    )
                    .onTapGesture {
                        selectedFilterName = filter.name
                    }
                    .contextMenu {
                        Button("Удалить", role: .destructive, action: { [weak filter] in remove(filter: filter) })
                    }
                }
                Spacer(minLength: 16)
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.never)
        .background(Color.themed)
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
        
        let allPreparedSpells = character.preparedSpells
        guard let selectedFilter else {
            characterPrepared = allPreparedSpells
            onFinish()
            return
        }
        
        Task.detached {
            let result = selectedFilter.satisfying(
                spells: allPreparedSpells,
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
        
        let allKnownSpells = character.knownSpells
        guard let selectedFilter else {
            characterKnown = allKnownSpells
            onFinish()
            return
        }
        
        Task.detached {
            let result = selectedFilter.satisfying(
                spells: allKnownSpells,
                allMaterials: materials,
                allTags: tags
            )
            characterKnown = result
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
