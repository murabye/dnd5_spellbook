//
//  SpellCellsRestoreView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.06.2024.
//

import SwiftUI

struct SpellCellsRestoreView: View {

    @Environment(\.modelContext) var modelContext
    @Binding var character: CharacterModel?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let character {
                    ForEach(character.levels.sortedList, id: \.0) { (level, spells) in
                        SpellCellsHeaderView(
                            character: $character,
                            cellLevel: level
                        )
                    }
                    Spacer()
                    Button(action: {
                        character.usedLevels = [:]
                        try? modelContext.save()
                    }, label: {
                        Text(character.characterClass != .warlock ? "Долгий отдых" : "Короткий отдых")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    })
                    .padding()
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Выберите персонажа")
                }
            }
            .navigationTitle("Управление ячейками")
        }
    }
}
