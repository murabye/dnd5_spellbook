//
//  CharacterClassPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI

struct MultipleElemsMenu<E: RawRepresentable>: View where E: FilterFormSelectable  {
    
    @Binding var selected: [E]
    @State var isPopoverVisible: Bool = false
    let notSelectedTitle: String
    let all: [E]
    
    var body: some View {
        Button {
            isPopoverVisible.toggle()
        } label: {
            Text(selected.isEmpty ? notSelectedTitle : selected.map(\.name).joined(separator: ", "))
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
                        Label(
                            title: { Text(elem.name) },
                            icon: {
                                if selected.contains(elem) {
                                    Image(systemName: "checkmark")
                                } else {
                                    Rectangle().background(Color.clear).tint(.clear).frame(width: 19, height: 20)
                                }
                            }
                        )
                        .padding(.vertical, 4)
                    }
                    
                    if elem != all.last {
                       Divider()
                    }
                }
            }
            .padding()
        }
    }
}
