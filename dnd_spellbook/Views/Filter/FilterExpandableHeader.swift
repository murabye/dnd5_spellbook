//
//  FilterExpandableHeader.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 18.12.2023.
//

import SwiftUI

struct FilterExpandableHeader: View {
    let title: String
    @Binding var isOpened: Bool
    let canSelectAll: Bool
    let selectAll: () -> Void
    
    var body: some View {
        HStack {
            Text(title).font(.title2)
            if canSelectAll {
                Button("Выбрать все", action: selectAll)
            }
            Spacer()
            Image(systemName: "chevron.up")
                .rotationEffect(isOpened ? .degrees(0) : .degrees(180))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isOpened.toggle()
        }
    }
}
