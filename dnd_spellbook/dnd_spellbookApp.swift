//
//  dnd_spellbookApp.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

@main
struct dnd_spellbookApp: App {
    
    @Environment(\.modelContext) var modelContext
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: Filter.self, Character.self, Tag.self, Spell.self, Material.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
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
