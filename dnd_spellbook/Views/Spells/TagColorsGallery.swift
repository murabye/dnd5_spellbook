//
//  TagColorsGallery.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 04.02.2024.
//

import SwiftUI

struct TagColorsGallery: View {
    @Binding var selected: TagColor?
    
    private let columns = [
        
        GridItem(.fixed(25)),
        GridItem(.fixed(25)),
        GridItem(.fixed(25)),
        GridItem(.fixed(25)),
        GridItem(.fixed(25)),
        GridItem(.fixed(25)),
        GridItem(.fixed(25))
    ]

    var body: some View {
        Grid {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(TagColor.allCases, id: \.self) { item in
                    item.backgroundColor
                        .colorWheelStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(
                                    item == selected ? item.backgroundColor : .gray,
                                    lineWidth: 1
                                )
                        )
                        .overlay {
                            Text(item == selected ? "a" : "A")
                                .foregroundStyle(item.foregroundColor)
                        }
                        .onTapGesture {
                            selected = item
                        }
                }
            }
        }
    }
}

extension View {
    func colorWheelStyle() -> some View {
        self
            .frame(width: 25, height: 25, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.white, lineWidth: 3)
            )
    }
}

//#Preview {
//    TagColorsGallery()
//}
