//
//  CharacterList.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 21.12.2023.
//

import SwiftData
import SwiftUI

struct CharacterList: View {
    @Query(sort: \Character.name) var characters: [Character]
    @State private var showingNew = false
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        GeometryReader { proxy in
            VStack {
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

                        ForEach(characters, id: \.self) { character in
                            CharacterListItem(
                                character: character,
                                isCompact: false
                            )
                            .onTapGesture { _ in
                                UserDefaults.standard.selectedId = character.id
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    NavigationLink("Страничка автора", value: NavWay.authorPage)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .background(
                Color(uiColor: UIColor.systemGroupedBackground)
            )
            .navigationTitle("Список персонажей")
            .fullScreenCover(
                isPresented: $showingNew,
                onDismiss: {
                    showingNew = false
                },
                content: {
                    if idiom == .phone {
                        CharacterCreationView()
                    } else {
                        CharacterCreationBigView()
                    }
                }
            )
        }
    }
}
