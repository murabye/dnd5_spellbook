//
//  SpellCellsView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 29.05.2024.
//

import SwiftUI

struct SpellCellsHeaderView: View {

    @Environment(\.modelContext) var modelContext
    @Binding var character: CharacterModel?

    var allCells: Int { character?.levels[cellLevel] ?? 0 }
    var filledCells: Int { character?.usedLevels[cellLevel] ?? 0 }
    
    let cellLevel: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(cellLevel) круг")
            Spacer()
            
            Button("-") {
                character?.usedLevels[cellLevel] = max(filledCells - 1, 0)
                try? modelContext.save()
            }
            .disabled((character?.usedLevels[cellLevel] ?? 0) < 1)
            .buttonStyle(.borderless)
            
            ForEach(0..<allCells, id: \.self) { cellNumber in
                Circle()
                    .stroke(.gray, lineWidth: 1)
                    .fill(cellNumber < filledCells ? .gray : .clear)
                    .frame(width: 10, height: 10)
            }
            
            Button("+") { 
                character?.usedLevels[cellLevel] = min(filledCells + 1, allCells)
                try? modelContext.save()
            }
            .disabled(filledCells >= allCells)
            .buttonStyle(.borderless)
        }
        .padding(.horizontal)
    }
}
