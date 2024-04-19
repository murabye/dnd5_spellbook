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

    @Environment(\.modelContext) var modelContext
    
    @State private var searchText = ""
    @State private var isLoading = false
    
    @Query var materials: [MaterialModel]
    @Query var tags: [Tag]
    @State var spells = [Spell]()

    var body: some View {
        ScrollView {
            LazyVStack {
                SpellListView(
                    spells: $spells,
                    character: $character,
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
        .navigationTitle("Поиск")
        .searchable(text: $searchText)
        .toolbar(content: {
            if isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
            }
        })
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .onChange(of: searchText, debounceTime: 0.3) { newValue in
            spells = []
            loadSpells()
        }
    }
    
    func loadSpells() {
        var fetchDescriptor = FetchDescriptor<Spell>(
            predicate: #Predicate { spell in
                if searchText.isEmpty {
                    return true
                } else {
                    return spell.name.localizedStandardContains(searchText)
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
            spells.append(contentsOf: newData)
            isLoading = false
        } else {
            isLoading = false
        }
    }
}
