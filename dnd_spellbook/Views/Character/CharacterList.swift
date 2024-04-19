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
    @State private var showingNew = false
    @Environment(\.modelContext) var modelContext

    @State var characterCreationLoading: Bool = false
    
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
                            Button("Удалить") { [weak character] in remove(character) }
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
            NavigationLink(value: NavWay.authorPage) {
                Text("Автор")
            }
        })
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
    }
    
    func remove(_ character: CharacterModel?) {
        guard let character else { return }
        if UserDefaults.standard.selectedId == character.id {
            UserDefaults.standard.selectedId = ""
            CharacterUpdateService.send()
        }

        modelContext.delete(character)
        try? modelContext.save()
    }
}
