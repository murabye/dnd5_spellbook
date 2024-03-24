//
//  SchoolPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI

struct SchoolPickerView: View {
    @State var selected: SpellSchool = SpellSchool.evocation
    var all: [SpellSchool] = SpellSchool.allCases
        
    var body: some View {
        VStack(spacing: 16) {
            if all.isEmpty {
                Text("Больше нечего добавить")
            } else {
                Picker("Школа", selection: $selected) {
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
            SchoolPickerView()
                .background(Color.white)
        }
    }
    .background(Color.cyan)
}
