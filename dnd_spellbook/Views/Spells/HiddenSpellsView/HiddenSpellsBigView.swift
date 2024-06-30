//
//  ContentView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

struct HiddenSpellsBigView: View {
    
    @Environment(\.modelContext) var modelContext
    
    let columnAmount: Int
    let allMaterials: [MaterialModel]
    let allTags: [Tag]
    
    @Binding var character: CharacterModel?

    // spells
    @State var hidden = [Int: [Spell]]()
    @State var hiddenFetchOffset = 0
    
    @State var changed = false
    
    var body: some View {
        ScrollView {
            VerticalWaterfallLayout(
                columns: columnAmount,
                spacingX: 16,
                spacingY: 16
            ) {
                SpellListView(
                    spellsByLevel: $hidden,
                    character: $character,
                    preparedSpellsMap: .constant([:]),
                    knownSpellsMap: .constant([:]),
                    pinIndex: 0,
                    canEdit: false,
                    name: .other,
                    onHide: { _ in },
                    onUnhide: { _ in },
                    onRemove: { spell in onRemove(spell) },
                    onKnow: { spell in onRemove(spell) },
                    onUnknow: { _ in },
                    onPrepare: { spell in onRemove(spell) },
                    onUnprepare: { _ in }
                )
            }
            LazyVStack {
                Rectangle().fill(Color(uiColor: .systemGroupedBackground)).onAppear { load() }
            }
        }
        .background(
            Color(uiColor: UIColor.systemGroupedBackground)
        )
        .navigationBarTitle("Скрытые")
        .appearOnce { load() }
    }

    // MARK: - spell loading
    func load() {
        var fetchDescriptor = FetchDescriptor<Spell>(
            predicate: #Predicate { spell in
                spell.isHidden == true
            },
            sortBy: [SortDescriptor(\.id)]
        )
        
        guard let totalAmount = try? modelContext.fetchCount(fetchDescriptor) else {
            return
        }

        fetchDescriptor.fetchLimit = 30
        fetchDescriptor.fetchOffset = min(totalAmount, hiddenFetchOffset)
        
        if totalAmount > hiddenFetchOffset + 1 {
            let newData = (try? modelContext.fetch(fetchDescriptor)) ?? []
            hiddenFetchOffset = hiddenFetchOffset + newData.count
            newData.forEach { spell in
                hidden[spell.level]?.append(spell)
            }
        }
    }

    // MARK: actions
    func onRemove(_ spell: Spell) {
        if let index = hidden[spell.level]?.firstIndex(of: spell) {
            hidden[spell.level]?.remove(at: index)
            hiddenFetchOffset = hiddenFetchOffset - 1
            changed = true
        }
    }
}
