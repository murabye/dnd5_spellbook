//
//  SpellEditView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct SpellEditView: View {
    let spell: Spell
    @State var description: String = ""
    @Query(sort: \Tag.text) var allTags: [Tag]
    @Query(sort: \MaterialModel.name) var allMaterials: [MaterialModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(spell.name).font(.title)
            TagLine(compact: false, edit: true, tags: spell.tags(allTags: allTags))
            Text(spell.components.name(allMaterials: allMaterials))
            
            HStack {
                Text(spell.typeOfAction.name)
                Spacer()
                Text(spell.duration.name)
            }
            
            Group {
                Divider()
                Text(spell.sources.map(\.name).joined(separator: ", "))
                    .foregroundStyle(Color.secondary)
                
                TextField(spell.labelling, text: $description, axis: .vertical)
                
                HStack {
                    Text(spell.school.name)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    Text(spell.classes.name)
                        .foregroundStyle(Color.secondary)
                }
                Divider()
            }
            
            HStack {
                Text(spell.level.levelName)
                Spacer()
                Text(spell.distantion.name)
            }
        }
        .contentShape(Rectangle())
        .padding()
    }
}

extension Int {
    
    var levelName: String {
        switch self {
        case 0:
            return "Заговор"
        default:
            return "\(self) ур."
        }
    }
}

