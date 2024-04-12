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
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    let descr: FetchDescriptor<Spell> = {
        var fetchDescriptor = FetchDescriptor<Spell>()
        fetchDescriptor.fetchLimit = 1
        return fetchDescriptor
    }()
    
    var needLoad: Bool {
        if let res = try? modelContext.fetchCount(descr), res > 0 {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        Group {
            if needLoad {
                mainView
            } else if stage != .done {
                DatabaseSetupView(stage: $stage)
            } else {
                mainView
            }
        }
        .animation(.easeIn, value: stage == .done)
    }
    
    var mainView: some View {
        Group {
            if idiom == .phone {
                NavigationStack {
                    MainView().background(Color(uiColor: .systemGroupedBackground))
                }
            } else {
                NavigationStack {
                    ColumnReader { columnAmount, safeArea in
                        MainBigView(columnAmount: columnAmount)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
        }
    }
}
