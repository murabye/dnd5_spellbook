//
//  SpellEditView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 19.12.2023.
//

import SwiftData
import SwiftUI

struct SpellEditView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    let spell: Spell
    @State var description: String
    @State var tags: [Tag]
    @State var isTagCreationPresented: Bool = false
    @Query(sort: \Tag.text) var allTags: [Tag]
    @Query(sort: \MaterialModel.name) var allMaterials: [MaterialModel]

    init(spell: Spell) {
        self.spell = spell
        self.description = spell.descrText
        self.tags = []
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    TagLine(compact: false, edit: true, tags: $tags) {
                        isTagCreationPresented.toggle()
                    }
                    .popover(isPresented: $isTagCreationPresented) {
                        TagSelectView(selectedTags: $tags)
                    }
                    
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
                        
                        TextField("Описание заклинания", text: $description, axis: .vertical)
                        
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
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                Button("Сохранить") {
                    saveUpdate()
                    dismiss()
                }
            }
            .navigationTitle(spell.name)
            .appearOnce {
                tags = spell.tags(allTags: allTags)
            }
        }
    }
    
    func saveUpdate() {
        if spell.descrText != description {
            spell.userDescription = description
        }
        
        let spellTags = spell.tags(allTags: allTags)
        if spellTags != tags {
            let tagActions = spell.userTagsActions
            
            var appendActions = [String]()
            var removeActions = [String]()
            
            for tag in tags {
                if !spellTags.contains(tag) {
                    appendActions.append(tag.id)
                }
            }
            
            for tag in spellTags {
                if !spellTags.contains(tag) {
                    removeActions.append(tag.id)
                }
            }
            
            for tagAction in tagActions {
                if tagAction.action, let removeIndex = removeActions.firstIndex(of: tagAction.tagId) {
                    removeActions.remove(at: removeIndex)
                } else if !tagAction.action, let appendIndex = appendActions.firstIndex(of: tagAction.tagId) {
                    appendActions.remove(at: appendIndex)
                }
            }
            
            let result = tagActions
                + removeActions.map { TagAction(action: false, tagId: $0) }
                + appendActions.map { TagAction(action: true, tagId: $0) }
            
            spell.userTagsActions = result
        }
        
        try? modelContext.save()
    }
}
