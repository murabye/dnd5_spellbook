//
//  ComponentCreationView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

struct ComponentCreationView: View {
    var distantions: [String]
    @State private var selected: String
    @State private var materialCost: String = ""
    @State private var materialAmount: String = ""
    @State private var materialTitle: String = ""

    init(canAddVoice: Bool, canAddHands: Bool) {
        if canAddHands, canAddVoice {
            distantions = ["Голос", "Руки", "Материал"]
            selected = "Голос"
        } else if canAddHands {
            distantions = ["Руки", "Материал"]
            selected = "Руки"
        } else if canAddVoice {
            distantions = ["Голос", "Материал"]
            selected = "Голос"
        } else {
            distantions = ["Материал"]
            selected = "Материал"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if distantions.count > 1 {
                Picker("Компоненты", selection: $selected) {
                    ForEach(distantions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            if selected == "Материал" {
                TextField("Название материала", text: $materialTitle, axis: .horizontal)
                    .textFieldStyle(.roundedBorder)

                TextField("Количество", text: $materialAmount, axis: .horizontal)
                    .textFieldStyle(.roundedBorder)

                TextField("Цена материалов", text: $materialCost, axis: .horizontal)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(Just(materialCost)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.materialCost = filtered
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
    ScrollView {
        VStack(spacing: 8) {
            ComponentCreationView(canAddVoice: true, canAddHands: true)
                .background(Color.white)
            ComponentCreationView(canAddVoice: true, canAddHands: false)
                .background(Color.white)
            ComponentCreationView(canAddVoice: false, canAddHands: true)
                .background(Color.white)
            ComponentCreationView(canAddVoice: false, canAddHands: false)
                .background(Color.white)
        }
    }
    .background(Color.cyan)
}
