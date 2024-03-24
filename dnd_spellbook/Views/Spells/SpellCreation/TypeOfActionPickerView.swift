//
//  TypeOfActionPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI

struct TypeOfActionPickerView: View {
    
    @State var selectedType: NoConreteActionType = .action
    @State var time: Int = 5
    var types: [NoConreteActionType] = NoConreteActionType.allCases

    var body: some View {
        VStack(spacing: 16) {
            if types.isEmpty {
                Text("Больше нечего добавить")
            } else {
                Picker("Тип действия", selection: $selectedType) {
                    ForEach(types, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            if selectedType == .time {
                Stepper("Минуты: \(time)", value: $time)
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
            TypeOfActionPickerView()
                .background(Color.white)
        }
    }
    .background(Color.cyan)
}
