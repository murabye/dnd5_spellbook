//
//  SectionIndexTitles.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.04.2024.
//

import Foundation
import UIKit
import SwiftUI

enum SectionsName: String, CaseIterable {
    
    case prepared = "Подготовленные"
    case known = "Известные"
    case other = "Прочие"
    case hidden = "Сокрытые"
    case search = "Поиск"
    
    var canHide: Bool {
        self == .other
    }
    
    var canExpand: Bool {
        self == .hidden
    }
}

struct SectionIndexTitleView: View {
    
    let name: SectionsName
    @Binding var isHidden: Bool
    @Binding var scrollOffset: CGPoint

    var body: some View {
        if name.canHide || name.canExpand {
            HStack {
                Text(name.rawValue)
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(isHidden || name.canExpand ? .degrees(0) : .degrees(90))
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
            .pinned(index: 0)
        } else {
            HStack {
                Text(name.rawValue)
                Spacer()
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .padding(.horizontal)
            .contentShape(Rectangle())
            .id(name.rawValue)
            .pinned(index: 0)
        }
    }
}

struct SectionIndexTitles: View {
    let proxy: ScrollViewProxy
    let titles: [SectionsName]
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
    
    func dragObserver(title: SectionsName) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }
    
    func dragObserver(geometry: GeometryProxy, title: SectionsName) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            DispatchQueue.main.async {
                proxy.scrollTo(title.rawValue, anchor: .top)
            }
        }
        return Rectangle().fill(Color.clear)
    }

    func sfSymbol(for deviceCategory: SectionsName) -> Image {
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
