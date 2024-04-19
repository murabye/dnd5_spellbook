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
    case search = "Поиск"
}

struct SectionIndexTitleView: View {
    
    let name: SectionsNames
    let canHide: Bool
    @Binding var isHidden: Bool
    
    var body: some View {
        HStack {
            Text(name.rawValue)
            Spacer()
            if canHide {
                Image(systemName: "chevron.right")
                    .rotationEffect(isHidden ? .degrees(0) : .degrees(90))
            }
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isHidden.toggle()
            }
        }
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
                sfSymbol(for: title)
                    .foregroundColor(.blue)
                    .background(dragObserver(title: title))
                    .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 4)
        .background(Color(uiColor: UIColor.systemGray6))
        .clipShape(Capsule())
        .frame(width: 20)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }
    
    func dragObserver(title: SectionsNames) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }
    
    func dragObserver(geometry: GeometryProxy, title: SectionsNames) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            DispatchQueue.main.async {
                proxy.scrollTo(title.rawValue, anchor: .top)
            }
        }
        return Rectangle().fill(Color.clear)
    }

    func sfSymbol(for deviceCategory: SectionsNames) -> Image {
        let systemName: String
        switch deviceCategory {
        case .prepared: systemName = "brain"
        case .known: systemName = "book"
        case .other: systemName = "tray"
        case .hidden: systemName = "eye.slash"
        case .search: systemName = "magnifyingglass"
        }
        return Image(systemName: systemName)
    }
}
