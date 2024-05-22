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
    @Query(sort: \Tag.id) var allTags: [Tag]
    @Query(sort: \MaterialModel.name) var allMaterials: [MaterialModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 2) {
                    Text("\(spell.level)")
                    if spell.canUpcast {
                        Image(systemName: "chevron.right.2")
                            .rotationEffect(.degrees(-90))
                            .font(.caption2)
                    }
                }
                .padding(.horizontal, 4)
                .background(.yellow)
                .clipShape(Capsule())
                
                Text(spell.name)
                    .font(.title)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(!collapsed ? 0 : 180))
            }
            
            TagLine(compact: collapsed, edit: false, tags: .constant(spell.tags(allTags: allTags)))
            Text(spell.components.name(allMaterials: allMaterials))
            
            if !collapsed {
                Group {
                    Divider()
                    if let engName = spell.engName {
                        Text(engName).foregroundStyle(Color.secondary)
                    }

                    Text(spell.sources.map(\.name).joined(separator: ", "))
                        .foregroundStyle(Color.secondary)
                    
                    Text(spell.descrText)
                        .foregroundStyle(Color.secondary)
                    
                    HStack {
                        Text("Школа \(spell.school.name.lowercased())")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(spell.classes.name)
                            .foregroundStyle(Color.secondary)
                    }
                    Divider()
                }
            }

            HStack {
                Text(spell.typeOfAction.name)
                Spacer()
                Text("\(spell.duration.name) \(spell.distantion.name)")
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
