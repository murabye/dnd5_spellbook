//
//  ComponentCreationView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import Combine
import SwiftUI

enum ComponentCreationElement {
    
    case somatic
    case verbal
    case authorPay(Int)
    case material(String, Int)
    
    var name: String {
        switch self {
        case .somatic: "руки"
        case .verbal: "голос"
        case let .authorPay(gold): "авторские отчисления (\(gold)зм)"
        case let .material(materialName, _): materialName
        }
    }
}

enum ComponentCreationElementType: String, CaseIterable {
    
    case somatic = "Руки"
    case verbal = "Голос"
    case authorPay = "Авторские отчисления"
    case material = "Материалы"
}

struct ComponentCreationView: View {
    
    var all = ComponentCreationElementType.allCases
    @State private var selected: [ComponentCreationElementType] = [] { didSet { updateBindedValue() } }
    @State private var materialName: String = "" { didSet { updateBindedValue() } }
    @State private var materialCost: String = "" { didSet { updateBindedValue() } }
    @State private var authorPrice: String = "" { didSet { updateBindedValue() } }
    @State private var isPopoverVisible = false
    
    @Binding var selectedComponents: [ComponentCreationElement]
    func updateBindedValue() {
        selectedComponents = []
        for componentType in selected {
            switch componentType {
            case .somatic: selectedComponents.append(.somatic)
            case .verbal: selectedComponents.append(.verbal)
            case .authorPay: selectedComponents.append(.authorPay(Int(authorPrice) ?? 2))
            case .material:
                if !materialName.isEmpty {
                    selectedComponents.append(.material(materialName, Int(materialCost) ?? 0))
                }
            }
        }
    }
    
    init(selectedComponents: Binding<[ComponentCreationElement]>) {
        self._selectedComponents = selectedComponents
        for component in selectedComponents.wrappedValue {
            switch component {
            case .somatic:
                selected.append(.somatic)
            case .verbal:
                selected.append(.verbal)
            case let .authorPay(price):
                selected.append(.authorPay)
                authorPrice = String(price)
            case let .material(name, price):
                selected.append(.material)
                materialName = name
                materialCost = String(price)
            }
        }
    }
    
    var body: some View {
        Button {
            isPopoverVisible.toggle()
        } label: {
            Text(selectedComponents.isEmpty ? "Компоненты" : selectedComponents.map(\.name).joined(separator: ", "))
                .multilineTextAlignment(.leading)
        }
        .popover(isPresented: $isPopoverVisible) {
            VStack(alignment: .leading) {
                ForEach(all, id: \.self) { elem in
                    Button {
                        if let index = selected.firstIndex(of: elem) {
                            selected.remove(at: index)
                        } else {
                            selected.append(elem)
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Label(
                                title: { Text(elem.rawValue) },
                                icon: {
                                    if selected.contains(elem) {
                                        Image(systemName: "checkmark")
                                    } else {
                                        Rectangle().background(Color.clear).tint(.clear).frame(width: 19, height: 20)
                                    }
                                }
                            )
                            .padding(.vertical, 4)
                            
                            if elem == .authorPay {
                                TextField("Золотых...", text: $authorPrice, axis: .horizontal)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onReceive(Just(authorPrice)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.authorPrice = filtered
                                        }
                                        if !newValue.isEmpty {
                                            updateBindedValue()
                                        }
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 19)
                            } else if elem == .material {
                                TextField("Название", text: $materialName, axis: .horizontal)
                                    .keyboardType(.default)
                                    .textFieldStyle(.roundedBorder)
                                    .onReceive(Just(materialName)) { newValue in
                                        if !newValue.isEmpty {
                                            updateBindedValue()
                                        }
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 19)
                                TextField("Золотых...", text: $materialCost, axis: .horizontal)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onReceive(Just(materialCost)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.materialCost = filtered
                                        }
                                        if !newValue.isEmpty {
                                            updateBindedValue()
                                        }
                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 19)
                            }
                            
                            if elem != .material {
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
