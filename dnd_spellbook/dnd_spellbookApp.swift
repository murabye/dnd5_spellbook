//
//  dnd_spellbookApp.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

/*
 TODO: VARVAR
 ресайз не помню
 скрытие клавиатуры
 скролл неправильный
 Скрыть прочие по умолчанию
 Жрец -> в известное
 Привязать фильтры к персонажам
 Пресет фильтров при добавлении персонажа
 Инициальный пресет фильтров
 */

import SwiftData
import SwiftUI

@main
struct dnd_spellbookApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: Filter.self, CharacterModel.self, Tag.self, Spell.self, MaterialModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Could not initialize ModelContainer \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DatabaseSetupIfNeededView()
        }
        .modelContainer(modelContainer)
    }
}
