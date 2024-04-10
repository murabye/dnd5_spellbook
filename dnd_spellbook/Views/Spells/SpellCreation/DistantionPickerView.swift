//
//  DistantionPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

struct DistantionPickerView: View {
    var distantions = ["Только вы", "Касание", "Футы", "Видимость", "Неограниченная"]
    @State private var selected = "Только вы" { didSet { updateBindedValue() } }
    @State private var feet: String = "" { didSet { updateBindedValue() } }
    @State private var isPopoverVisible = false

    @Binding var selectedDistantion: Distantion
    func updateBindedValue() {
        if selected == distantions[0] {
            selectedDistantion = .onlyYou
        } else if selected == distantions[1] {
            selectedDistantion = .touches
        } else if selected == distantions[2], !feet.isEmpty, let num = Int(feet) {
            selectedDistantion = .feet(num)
        } else if selected == distantions[3] {
            selectedDistantion = .visibility
        } else if selected == distantions[4] {
            selectedDistantion = .full
        }
    }
    
    init(selectedDistantion: Binding<Distantion>) {
        self._selectedDistantion = selectedDistantion
        switch selectedDistantion.wrappedValue {
        case .onlyYou: selected = distantions[0]
        case .touches: selected = distantions[1]
        case .visibility: selected = distantions[3]
        case .full: selected = distantions[4]
        case let .feet(amount): selected = distantions[2]; feet = String(amount)
        }
    }

    var body: some View {
        Button {
            isPopoverVisible.toggle()
        } label: {
            Text(selectedDistantion.name)
        }
        .popover(isPresented: $isPopoverVisible) {
            VStack(alignment: .leading) {
                ForEach(distantions, id: \.self) { elem in
                    Button {
                        selected = elem
                    } label: {
                        VStack(alignment: .leading) {
                            Label(
                                title: { Text(elem) },
                                icon: {
                                    if selected == elem {
                                        Image(systemName: "checkmark")
                                    } else {
                                        Rectangle().background(Color.clear).tint(.clear).frame(width: 19, height: 20)
                                    }
                                }
                            )
                            .padding(.vertical, 4)
                            
                            if elem == "Футы" {
                                TextField("Футы", text: $feet, axis: .horizontal)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onReceive(Just(feet)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.feet = filtered
                                        }
                                        if !newValue.isEmpty {
                                            updateBindedValue()
                                        }
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 19)
                            }
                            
                            if elem != "Неограниченная" {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
