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
                    ColumnReader { columnAmount, safeArea in CharacterCreationView(safeArea: safeArea) }
                } else {
                    NavigationStack {
                        ColumnReader { columnAmount, safeArea in
                            CharacterCreationBigView(columnAmount: columnAmount)
                        }
                        .background(Color(uiColor: .systemGroupedBackground))
                    }
                }
            }
        )
    }
}
