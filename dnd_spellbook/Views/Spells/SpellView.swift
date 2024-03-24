//
//  SpellView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.12.2023.
//

import SwiftData
import SwiftUI

struct SpellView: View {
    let spell: Spell
    @State var collapsed: Bool
    @Query var allTags: [Tag]
    @Query(sort: \Material.name) var allMaterials: [Material]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(spell.name)
                    .font(.title)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(!collapsed ? 0 : 180))
            }
            
            TagLine(compact: collapsed, edit: false, tags: spell.tags(allTags: allTags))
            Text(spell.components.name(allMaterials: allMaterials))

            HStack {
                Text(spell.typeOfAction.name)
                Spacer()
                Text(spell.duration.name)
            }
            
            if !collapsed {
                Group {
                    Divider()
                    Text(spell.sources.map(\.name).joined(separator: ", "))
                        .foregroundStyle(Color.secondary)
                    
                    Text(spell.labelling)
                        .foregroundStyle(Color.secondary)
                    
                    HStack {
                        Text(spell.school.name)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(spell.classes.name)
                            .foregroundStyle(Color.secondary)
                    }
                    Divider()
                }
            }

            HStack {
                Text(spell.level.levelName)
                Spacer()
                Text(spell.distantion.name)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(
                .spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7)
            ) {
                collapsed.toggle()
            }
        }
    }
}
