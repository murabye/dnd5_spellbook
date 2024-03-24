//
//  CharacterClassCreationPicker.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 18.12.2023.
//

import SwiftUI

struct CharacterClassCreationPicker<E: RawRepresentable>: View where E: Archetype {
    
    @Binding var selected: E

    let allCases: [E]
    let isCompact: Bool
    
    var body: some View {
        if isCompact {
            Picker(E.description, selection: $selected) {
                ForEach(allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.menu)
        } else {
            Picker(E.description, selection: $selected) {
                ForEach(allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

#Preview {
    CharacterClassCreationPicker(
        selected: .constant(DruidCircle.land),
        allCases: DruidCircle.allCases,
        isCompact: false
    )
}
