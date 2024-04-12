//
//  SectionIndexTitles.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.04.2024.
//

import Foundation
import SwiftUI

enum SectionsNames: String, CaseIterable {
    
    case prepared = "Подготовленные"
    case known = "Известные"
    case other = "Прочие"
    case hidden = "Сокрытые"
}

struct SectionIndexTitleView: View {
    
    let name: SectionsNames
    
    var body: some View {
        HStack {
            Text(name.rawValue)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, -16)
        .id(name.rawValue)
    }
}

struct SectionIndexTitles: View {
    let proxy: ScrollViewProxy
    let titles: [SectionsNames]
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                SectionIndexTitle(image: sfSymbol(for: title))
                    .onTapGesture {
                        proxy.scrollTo(title.rawValue)
                    }
            }
        }
    }
    
    func sfSymbol(for deviceCategory: SectionsNames) -> Image {
        let systemName: String
        switch deviceCategory {
        case .prepared: systemName = "brain"
        case .known: systemName = "book"
        case .other: systemName = "tray"
        case .hidden: systemName = "eye.slash"
        }
        return Image(systemName: systemName)
    }
}

struct SectionIndexTitle: View {
    let image: Image
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .foregroundColor(Color(uiColor: UIColor.systemGray6))
            .frame(width: 20, height: 20)
            .overlay(
                image.foregroundColor(.blue)
            )
    }
}
