//
//  DistantionPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

struct DistantionPickerView: View {
    var distantions = ["Только вы", "Касание", "Футы"]
    @State private var selected = "Только вы"
    @State private var feet: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Picker("Дистанция", selection: $selected) {
                ForEach(distantions, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            
            if selected == "Футы" {
                TextField("Футы", text: $feet, axis: .horizontal)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(Just(feet)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.feet = filtered
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
    DistantionPickerView()
}
