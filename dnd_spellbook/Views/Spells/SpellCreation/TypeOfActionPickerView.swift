//
//  TypeOfActionPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

struct TypeOfActionPickerView: View {
    let all = NoConreteActionType.allCases
    @State var selected: NoConreteActionType { didSet { updateBindedValue() } }
    @State var time: String = "" { didSet { updateBindedValue() } }
    @State private var isPopoverVisible = false

    @Binding var selectedType: TypeOfAction
    func updateBindedValue() {
        switch selected {
        case .action: selectedType = .action
        case .bonus: selectedType = .bonus
        case .reaction: selectedType = .reaction
        case .time: let minutes = Int(time) ?? 10; selectedType = .time(minutes: minutes)
        }
    }
    
    init(selectedType: Binding<TypeOfAction>) {
        self._selectedType = selectedType
        
        switch selectedType.wrappedValue {
        case .action: selected = .action
        case .bonus: selected = .bonus
        case .reaction: selected = .reaction
        case let .time(minutes): selected = .time; time = String(minutes)
        }
    }

    var body: some View {
        Button {
            isPopoverVisible.toggle()
        } label: {
            Text(selected.name)
        }
        .popover(isPresented: $isPopoverVisible) {
            VStack(alignment: .leading) {
                ForEach(all, id: \.self) { elem in
                    Button {
                        selected = elem
                    } label: {
                        VStack(alignment: .leading) {
                            Label(
                                title: { Text(elem.name) },
                                icon: {
                                    if selected == elem {
                                        Image(systemName: "checkmark")
                                    } else {
                                        Rectangle().background(Color.clear).tint(.clear).frame(width: 19, height: 20)
                                    }
                                }
                            )
                            .padding(.vertical, 4)
                            
                            if elem == .time {
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
                            } else {
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
