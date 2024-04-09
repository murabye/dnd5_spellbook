//
//  ContentView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

enum NavWay: Int, Hashable {
    
    case characterList
    case authorPage
    case filterCreate
}

struct MainView: View {

    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @Environment(\.modelContext) var modelContext

    @Query(sort: \Filter.name) var filters: [Filter] = []
    @AppStorage(UserDefaults.Constants.selectedFilterName) var selectedFilterName: String?

    var selectedFilter: Filter? {
        filters.first { $0.name == selectedFilterName }
    }

    @Query(filter: #Predicate<Spell> { spell in
        !spell.isHidden
    }, sort: \Spell.id) var other: [Spell]
    
    @Query(filter: #Predicate<Spell> { spell in
        spell.isHidden
    }, sort: \Spell.id) var hidden: [Spell]
    
    @State var character: CharacterModel? = nil

    @Query var materials: [MaterialModel]
    @Query var tags: [Tag]

    func recallCharacter() {
        guard let userId = UserDefaults.standard.selectedId, !userId.isEmpty else {
            character = nil
            return
        }
        var fetchDescriptor = FetchDescriptor<CharacterModel>(predicate: #Predicate { character in
            character.id == userId
        })
        fetchDescriptor.fetchLimit = 1
        character = (try? modelContext.fetch(fetchDescriptor))?.first
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    ScrollViewReader { scrollProxy in
                        ZStack {
                            ScrollView {
                                header("Подготовленные")
                                SpellListView(
                                    spells: selectedFilter?.satisfying(
                                        spells: character?.preparedSpells ?? [],
                                        allMaterials: materials,
                                        allTags: tags
                                    ) ?? character?.preparedSpells ?? [],
                                    columns: max(Int(proxy.size.width / 300), 1), 
                                    character: $character
                                ).padding(.horizontal)

                                header("Известные")
                                SpellListView(
                                    spells: selectedFilter?.satisfying(
                                        spells: character?.knownSpells ?? [],
                                        allMaterials: materials,
                                        allTags: tags
                                    ) ?? character?.knownSpells ?? [],
                                    columns: max(Int(proxy.size.width / 300), 1),
                                    character: $character
                                ).padding(.horizontal)

                                header("Прочие")
                                SpellListView(
                                    spells: selectedFilter?.satisfying(spells: other, allMaterials: materials, allTags: tags) ?? other,
                                    columns: max(Int(proxy.size.width / 300), 1),
                                    character: $character
                                ).padding(.horizontal)
                                
                                header("Сокрытые")
                                SpellListView(
                                    spells: selectedFilter?.satisfying(spells: hidden, allMaterials: materials, allTags: tags) ?? hidden,
                                    columns: max(Int(proxy.size.width / 300), 1),
                                    character: $character
                                ).padding(.horizontal)

                                Spacer(minLength: 16)
                            }
                            sectionIndexTitles(proxy: scrollProxy)
                        }
                    }
                    
                    toolbar
                }
            }
            .background(
                Color(uiColor: UIColor.systemGroupedBackground)
            )
            .navigationBarTitle("Заклинания")
            .toolbar(content: {
                NavigationLink(value: NavWay.characterList) {
                    CharacterListItem(
                        character: character,
                        isCompact: true
                    )
                }
            })
            .navigationDestination(for: NavWay.self) { navWay in
                switch navWay {
                case .characterList: CharacterList()
                case .authorPage: AuthorPage()
                case .filterCreate: 
                    if idiom == .phone {
                        FilterSetupView()
                    } else {
                        FilterSetupBigView()
                    }
                }
            }
        }
        .onAppear {
            recallCharacter()
        }
        .onReceive(CharacterUpdateService.publisher()) { _ in
            recallCharacter()
        }
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

                ForEach(filters, id: \.self) { filter in
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
                }
                Spacer(minLength: 16)
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.never)
        .background(Color.white)
    }
    
    private func header(_ name: String) -> some View {
        HStack {
            Text(name)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, -16)
        .id(name)
    }
    
    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(
            proxy: proxy,
            titles: [
                "Известные",
                "Подготовленные",
                "Прочие",
                "Сокрытые"
            ]
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    }
}

struct SectionIndexTitles: View {
    let proxy: ScrollViewProxy
    let titles: [String]
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                SectionIndexTitle(image: sfSymbol(for: title))
                    .background(dragObserver(title: title))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }
    
    func dragObserver(title: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }
    
    func dragObserver(geometry: GeometryProxy, title: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            DispatchQueue.main.async {
                proxy.scrollTo(title, anchor: .top)
            }
        }
        return Rectangle().fill(Color.clear)
    }
    
    func sfSymbol(for deviceCategory: String) -> Image {
        let systemName: String
        switch deviceCategory {
        case "Подготовленные": systemName = "brain"
        case "Известные": systemName = "book"
        case "Прочие": systemName = "tray"
        default: systemName = "eye.slash"
        }
        return Image(systemName: systemName)
    }
}

struct SectionIndexTitle: View {
    let image: Image
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .foregroundColor(Color(uiColor: UIColor.systemGray6))
            .frame(width: 20, height: 20)
            .overlay(
                image.foregroundColor(.blue)
            )
    }
}
