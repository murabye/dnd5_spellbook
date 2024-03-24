//
//  SourcesPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI

struct SourcesPickerView: View {
    @State var selected: Sources = Sources.playerHandbook
    var all: [Sources] = Sources.allCases
    
    var body: some View {
        VStack(spacing: 16) {
            if all.isEmpty {
                Text("Больше нечего добавить")
            } else {
                Picker("Источник", selection: $selected) {
                    ForEach(all, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(.wheel)
            }
            
            Button {
                print("done")
            } label: {
                Text("Принять")
                    .padding(2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ScrollView {
        VStack {
            SourcesPickerView().background(Color.white)
        }
    }
    .background(Color.cyan)
}
