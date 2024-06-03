//
//  CharacterList.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 21.12.2023.
//

import SwiftData
import SwiftUI

struct CharacterList: View {
    @Query(sort: \CharacterModel.name) var characters: [CharacterModel]
    @Query var tags: [Tag]
    @State private var showingNew = false
    @State private var showingImport = false
    @Environment(\.modelContext) var modelContext

    @State private var editingCharacter: CharacterModel? = nil
    @State var characterCreationLoading: Bool = false
    @State var shareText: ShareText?

    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(
                            .fixed(proxy.size.width / 3),
                            spacing: 0
                        ),
                        count: Int(proxy.size.width / 120)
                    ),
                    spacing: 12
                ) {
                    Button(action: {
                        showingNew = true
                    }, label: {
                        CharacterListAppendItem(isSingle: characters.isEmpty)
                    })
                    
                    ForEach(characters, id: \.id) { character in
                        CharacterListItem(
                            character: character,
                            isCompact: false
                        )
                        .onTapGesture { _ in
                            UserDefaults.standard.selectedId = character.id
                            CharacterUpdateService.send()
                        }
                        .contextMenu {
                            Button("Экспорт") { [weak character] in export(character) }
                            Button("Редактировать") { [weak character] in edit(character) }
                            Button("Удалить", role: .destructive) { [weak character] in remove(character) }
                        }
                    }
                }
            }
        }
        .background(
            Color(uiColor: UIColor.systemGroupedBackground)
        )
        .navigationTitle("Список персонажей")
        .toolbar(content: {
            Button("Импорт") { showingImport = true }
            NavigationLink(value: NavWay.authorPage) {
                Text("Автор")
            }
        })
        .sheet(item: $shareText) { shareText in
            ActivityView(text: shareText.text)
        }
        .fullScreenCover(isPresented: $showingImport) {
            CharacterImportView()
        }
        .fullScreenCover(
            isPresented: $showingNew,
            onDismiss: {
                showingNew = false
            },
            content: {
                if idiom == .phone {
                    NavigationStack {
                        ColumnReader { columnAmount, safeArea in
                            CharacterCreationView(
                                isLoading: $characterCreationLoading,
                                safeArea: safeArea
                            )
                        }
                    }
                    .interactiveDismissDisabled(characterCreationLoading)
                } else {
                    NavigationStack {
                        ColumnReader { columnAmount, safeArea in
                            CharacterCreationBigView(
                                columnAmount: columnAmount,
                                isLoading: $characterCreationLoading
                            )
                        }
                        .background(Color(uiColor: .systemGroupedBackground))
                    }
                    .interactiveDismissDisabled(characterCreationLoading)
                }
            }
        )
        .fullScreenCover(item: $editingCharacter) { character in
            if idiom == .phone {
                NavigationStack {
                    ColumnReader { columnAmount, safeArea in
                        CharacterEditView(
                            isLoading: $characterCreationLoading,
                            safeArea: safeArea,
                            characterId: character.id,
                            initialImageUrl: character.imageUrl,
                            initialCharacterName: character.name,
                            selectedClass: character.characterClass ?? .nothing,
                            initialPrepared: character.preparedSpells,
                            initialKnown: character.knownSpells,
                            characterName: character.name,
                            maxLevel: character.levels.maxLevel,
                            levels: character.levels, 
                            initialUsedLevels: character.usedLevels
                        )
                    }
                }
                .interactiveDismissDisabled(characterCreationLoading)
            } else {
                NavigationStack {
                    ColumnReader { columnAmount, safeArea in
                        CharacterEditBigView(
                            columnAmount: columnAmount,
                            isLoading: $characterCreationLoading,
                            characterId: character.id,
                            initialImageUrl: character.imageUrl,
                            initialCharacterName: character.name,
                            selectedClass: character.characterClass ?? .nothing,
                            initialPrepared: character.preparedSpells,
                            initialKnown: character.knownSpells,
                            characterName: character.name,
                            maxLevel: character.levels.maxLevel,
                            levels: character.levels,
                            initialUsedLevels: character.usedLevels
                        )
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
                .interactiveDismissDisabled(characterCreationLoading)
            }
        }
    }
    
    func remove(_ character: CharacterModel?) {
        guard let character else { return }
        
        let id = character.id
        let fetchDescriptor = FetchDescriptor<Filter>(predicate: #Predicate { filter in
            filter.character == id
        })

        let filters: [Filter] = (try? modelContext.fetch(fetchDescriptor)) ?? []
        for filter in filters {
            modelContext.delete(filter)
        }
        
        if UserDefaults.standard.selectedId == character.id {
            UserDefaults.standard.selectedId = ""
            CharacterUpdateService.send()
        }

        modelContext.delete(character)
        try? modelContext.save()
    }
    
    func export(_ character: CharacterModel?) {
        guard let character else { return }
        
        let exportModel = CharacterExportModel(from: character, allTags: tags)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(exportModel) else { return }
        let string = String(decoding: data, as: UTF8.self)
        shareText = ShareText(text: string)
    }

    func edit(_ character: CharacterModel?) {
        self.editingCharacter = character
    }
}
