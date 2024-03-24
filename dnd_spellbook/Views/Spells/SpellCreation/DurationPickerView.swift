//
//  DurationPicker.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

struct DurationPicker: View {
    var durations = ["Мгновенно", "Раунды", "Время"]
    @State private var selected = "Мгновенно"
    @State private var raundes: String = ""
    @State private var time: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Picker("Длительность", selection: $selected) {
                ForEach(durations, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            
            if selected == "Раунды" {
                TextField("Раунды", text: $raundes, axis: .horizontal)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(Just(raundes)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.raundes = filtered
                        }
                    }
            } else if selected == "Время" {
                TextField("Минуты", text: $time, axis: .horizontal)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(Just(time)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.time = filtered
                        }
                    }
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
    DurationPicker()
}
