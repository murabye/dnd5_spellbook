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

    @Query(sort: \Filter.name) var filters: [Filter] = []
    @AppStorage(UserDefaults.Constants.selectedFilterName) var selectedFilterName: String?
    var selectedFilter: Filter? {
        filters.first { $0.name == selectedFilterName }
    }
    
    let prepared: [Spell] = []
    let known: [Spell] = []
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    @Query(filter: #Predicate<Spell> { spell in
        !spell.isHidden
    }, sort: \Spell.id) var other: [Spell]
    @Query(filter: #Predicate<Spell> { spell in
        spell.isHidden
    }, sort: \Spell.id) var hidden: [Spell]
    
    @Environment(\.modelContext) var modelContext
    @AppStorage(UserDefaults.Constants.selectedId) static var selectedId: String?
    @Query(filter: #Predicate<Character> {
        $0.id == selectedId ?? ""
    }) var character: [Character]
    
    @Query var materials: [Material]
    @Query var tags: [Tag]

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    ScrollViewReader { scrollProxy in
                        ZStack {
                            ScrollView {
                                header("Подготовленные")
                                spellList(
                                    selectedFilter?.satisfying(spells: prepared, allMaterials: materials, allTags: tags) ?? prepared,
                                    columns: max(Int(proxy.size.width / 300), 1)
                                )
                                                                
                                header("Известные")
                                spellList(
                                    selectedFilter?.satisfying(spells: known, allMaterials: materials, allTags: tags) ?? known,
                                    columns: max(Int(proxy.size.width / 300), 1)
                                )
                                header("Прочие")
                                spellList(
                                    selectedFilter?.satisfying(spells: other, allMaterials: materials, allTags: tags) ?? other,
                                    columns: max(Int(proxy.size.width / 300), 1)
                                )
                                header("Сокрытые")
                                spellList(
                                    selectedFilter?.satisfying(spells: hidden, allMaterials: materials, allTags: tags) ?? hidden,
                                    columns: max(Int(proxy.size.width / 300), 1)
                                )
                                
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
                        character: character.first,
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
    
    private func spellList(_ spells: [Spell], columns: Int) -> some View {
        SpellListView(spells: spells, columns: columns)
            .padding(.horizontal)
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

#Preview {
    MainView()
}
