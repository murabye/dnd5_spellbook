//
//  SpellListView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftUI

struct SpellListView: View {
    let spells: [Spell]
    let columns: Int
    @Environment(\.modelContext) var modelContext
    @AppStorage(UserDefaults.Constants.selectedId) var selectedId: String?
    
    var body: some View {
        VerticalWaterfallLayout(
            columns: columns,
            spacingX: 16,
            spacingY: 16
        ) {
            ForEach(
                spells,
                id: \.id
            ) { spell in
                    SpellView(
                        spell: spell,
                        collapsed: true
                    )
                    .contextMenu {
                        if let selectedId, !selectedId.isEmpty {
                            Button("Выучить", action: {})
                            Button("Подготовить", action: {})
                            Button("Забыть", action: {})
                            Button("Отложить", action: {})
                            Divider()
                        }
                        
                        if spell.isHidden {
                            Button("Открыть", action: { [weak spell] in unhide(spell: spell) })
                        } else {
                            Button("Спрятать", action: { [weak spell] in hide(spell: spell) })
                        }
                        
                        Button("Править", action: {})
                    }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.systemGroupedTableContent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical, 2)
            }
        }
    }
    
    func hide(spell: Spell?) {
        guard let spell,
              !spell.isHidden else {
            return
        }
        spell.isHidden = true
        try? modelContext.save()
    }
    
    func unhide(spell: Spell?) {
        guard let spell,
              spell.isHidden else {
            return
        }
        spell.isHidden = false
        try? modelContext.save()
    }
}
