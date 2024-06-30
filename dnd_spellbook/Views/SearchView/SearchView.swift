//
//  SearchView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.04.2024.
//

import Foundation
import SwiftData
import SwiftUI

struct SearchView: View {
    
    @Binding var character: CharacterModel?

    @Binding var preparedSpellsMap: [String: Bool]
    @Binding var knownSpellsMap: [String: Bool]
    
    @Environment(\.modelContext) var modelContext
    
    @State private var searchText = ""
    @State private var isLoading = false
    
    @Query var materials: [MaterialModel]
    @Query var tags: [Tag]
    @State var spells = [Int: [Spell]]()
    @State var spellCount = 0

    var body: some View {
        ScrollView {
            LazyVStack {
                SpellListView(
                    spellsByLevel: $spells,
                    character: $character,
                    preparedSpellsMap: $preparedSpellsMap,
                    knownSpellsMap: $knownSpellsMap,
                    pinIndex: 0,
                    canEdit: false,
                    name: .search,
                    onHide: { _ in },
                    onUnhide: { _ in },
                    onRemove: { _ in },
                    onKnow: { _ in },
                    onUnknow: { _ in },
                    onPrepare: { _ in },
                    onUnprepare: { _ in }
                )
                
                Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { loadSpells() }
            }
            .padding()
        }
        .pinContainer()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Поиск")
        .searchable(text: $searchText)
        .toolbar(content: {
            if isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
            }
        })
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .onChange(of: searchText, debounceTime: 0.3) { newValue in
            spells = [:]
            spellCount = 0
            loadSpells()
        }
    }
    
    
    func loadSpells() {
        var fetchDescriptor = FetchDescriptor<Spell>(
            predicate: #Predicate { spell in
                if searchText.isEmpty {
                    return true
                } else if let descr = spell.userDescription {
                    return spell.name.localizedStandardContains(searchText)
                        || spell.labelling.localizedStandardContains(searchText)
                        || descr.localizedStandardContains(searchText)
                } else if let eng = spell.engName {
                    return spell.name.localizedStandardContains(searchText)
                        || spell.labelling.localizedStandardContains(searchText)
                        || eng.localizedStandardContains(searchText)
                } else {
                    return spell.name.localizedStandardContains(searchText)
                        || spell.labelling.localizedStandardContains(searchText)
                }
            },
            sortBy: [SortDescriptor(\.id)]
        )
        isLoading = true
        guard let totalAmount = try? modelContext.fetchCount(fetchDescriptor) else {
            isLoading = false
            return
        }

        fetchDescriptor.fetchLimit = 30
        fetchDescriptor.fetchOffset = min(totalAmount, spells.count)
        
        if totalAmount > spells.count {
            let newData = (try? modelContext.fetch(fetchDescriptor)) ?? []
            for spell in newData {
                spells[spell.level]?.append(contentsOf: newData)
            }
            spellCount = spellCount + newData.count
            isLoading = false
        } else {
            isLoading = false
        }
    }
}
