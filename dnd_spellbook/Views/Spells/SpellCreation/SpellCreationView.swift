//
//  SpellCreationView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 17.12.2023.
//

import SwiftData
import SwiftUI

struct SpellCreationView: View {
    
    @State var name: String = ""
    @State var description: String = ""
    @State var components: [Component] = []
    @State var classes: [CharacterClass] = []
    @State var typeOfAction: TypeOfAction = .action
    @State var school: SpellSchool = .evocation
    @State var source: Sources = .playerHandbook
    @State var level: Int = 0
    @State var duration: Duration = .instantly
    @State var distantion: Distantion = .onlyYou
    @State var concentration: Bool = false

    @Query(sort: \Tag.text) var allTags: [Tag]
    @Query(sort: \Material.name) var allMaterials: [Material]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Название", text: $name, axis: .vertical)
                TagLine(compact: false, edit: true, tags: allTags)
                
                HStack {
                    Button(duration.name) {
                        print("duration")
                    }
                    Spacer()
                    Button(distantion.name) {
                        print("distantion")
                    }
                }
                
                Toggle("Концентрация", isOn: $concentration)
                
                Text(.init(
                    "Компоненты: "
                    + components.name(allMaterials: allMaterials)
                    + "... [Добавить компонент](add)"
                ))
                .environment(\.openURL, OpenURLAction { url in
                    print(url.absoluteString)
                    return .handled
                })
                
                Text(.init(
                    "Классы: "
                    + classes.name
                    + "... [Добавить класс](add)"
                ))
                .environment(\.openURL, OpenURLAction { url in
                    print(url.absoluteString)
                    return .handled
                })
                
                HStack {
                    Button(typeOfAction.name) {
                        print("typeOfAction")
                    }
                    Spacer()
                    Button(school.name) {
                        print("School")
                    }
                }
                
                TextField("Описание", text: $description, axis: .vertical)
                
                HStack {
                    Button(source.name) {
                        print("source")
                    }
                    Spacer()
                    Button(level.levelName) {
                        print("level name")
                    }
                }
            }
            .contentShape(Rectangle())
            .padding()
        }
        .navigationTitle("Создание заклинания")
    }
}

#Preview {
    MainActor.assumeIsolated {
        SpellCreationView()
    }
}
