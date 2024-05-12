//
//  dnd_spellbookApp.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

// ПЛАВАЮЩЕЕ
// почему-то не отображаются персонажи иногда хз почему
// почему-то иногда криво обрезка

// ДОЛГО
// на айфоне сделать меню с кнопками в стороны?
// экспорт персонажа
// мб добавить англ название спелла? - и поиск по англ названию
// добавить мультикласс (фильтры и при создании)

// СРЕДНЕ
// мб группировка по кругам
// подумать с ячейками - куда засунуть как отдыхать
// переверстать панель фильтров

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
