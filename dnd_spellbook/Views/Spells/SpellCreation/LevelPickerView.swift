//
//  LevelPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI

struct LevelPickerView: View {
    @State var selected: Int = 0
    var all: [Int] = Array(0...9)
    
    var body: some View {
        VStack(spacing: 16) {
            if all.isEmpty {
                Text("Больше нечего добавить")
            } else {
                Picker("Уровень", selection: $selected) {
                    ForEach(all, id: \.self) {
                        Text($0.levelName)
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
            LevelPickerView().background(Color.white)
        }
    }
    .background(Color.cyan)
}
