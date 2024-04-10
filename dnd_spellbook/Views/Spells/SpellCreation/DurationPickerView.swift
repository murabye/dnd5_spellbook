//
//  DurationPicker.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

struct DurationPickerView: View {
    var durations = ["Мгновенно", "Раунды", "Время", "Несколько", "Пока не рассеется"]
    @State private var isPopoverVisible = false
    
    @State private var selected: String = "Мгновенно" {
        didSet { updateBindedValue() }
    }
    
    @State private var raundes: String = "" {
        didSet { updateBindedValue() }
    }
    
    @State private var time: String = "" {
        didSet { updateBindedValue() }
    }
    
    @Binding var selectedDuration: Duration
    func updateBindedValue() {
        if selected == durations[0] {
            selectedDuration = .instantly
        } else if selected == durations[1], !raundes.isEmpty, let num = Int(raundes) {
            selectedDuration = .raundes(num)
        } else if selected == durations[2], !time.isEmpty, let num = Int(time) {
            selectedDuration = .time(minutes: num)
        } else if selected == durations[3] {
            selectedDuration = .many
        } else if selected == durations[4] {
            selectedDuration = .clause
        }
    }
    
    init(selectedDuration: Binding<Duration>) {
        self._selectedDuration = selectedDuration
        switch selectedDuration.wrappedValue {
        case .clause: selected = durations[4]
        case .instantly: selected = durations[0]
        case .many: selected = durations[3]
        case let .raundes(raundesAmount): selected = durations[1]; raundes = String(raundesAmount)
        case let .time(minutesAmount): selected = durations[2]; time = String(minutesAmount)
        }
    }
    
    var body: some View {
        Button {
            isPopoverVisible.toggle()
        } label: {
            Text(selectedDuration.name)
        }
        .popover(isPresented: $isPopoverVisible) {
            VStack(alignment: .leading) {
                ForEach(durations, id: \.self) { elem in
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
                            
                            if elem == "Раунды" {
                                TextField("Раунды", text: $raundes, axis: .horizontal)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onReceive(Just(raundes)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.raundes = filtered
                                        }
                                        if !newValue.isEmpty {
                                            updateBindedValue()
                                        }
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 19)
                            } else if elem == "Время" {
                                TextField("Минуты", text: $time, axis: .horizontal)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onReceive(Just(time)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.time = filtered
                                        }
                                        if !newValue.isEmpty {
                                            updateBindedValue()
                                        }
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 19)
                            }
                            
                            if elem != "Пока не рассеется" {
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
