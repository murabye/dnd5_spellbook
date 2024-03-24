//
//  dnd_spellbookApp.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 16.12.2023.
//

import SwiftData
import SwiftUI

struct DatabaseSetupIfNeededView: View {
    
    @Environment(\.modelContext) var modelContext
    @State var stage: DatabaseSetupView.Stage = .preparing
    
    let descr: FetchDescriptor<Spell> = {
        var fetchDescriptor = FetchDescriptor<Spell>()
        fetchDescriptor.fetchLimit = 1
        return fetchDescriptor
    }()
    
    var needLoad: Bool {
        if let res = try? modelContext.fetch(descr),
           !res.isEmpty {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        Group {
            if needLoad {
                MainView()
            } else if stage != .done {
                DatabaseSetupView(stage: $stage)
            } else {
                MainView()
            }
        }
        .animation(.easeIn, value: stage == .done)
    }
}
