//
//  TestableScrollView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 05.06.2024.
//

import UIKit
import SwiftUI

private enum Constants {
    
    static var coordinateSpace = "PinScrollView"
    static var pinViewHeight: Int = 20
}

private struct PinnedModifier: ViewModifier {
    
    let index: Int
    
    var indexOffset: CGFloat {
        CGFloat(index * Constants.pinViewHeight)
    }
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .offset(y: max(-proxy.frame(in: .named(Constants.coordinateSpace)).minY + indexOffset, 0))
            //
        }
        .zIndex(Double(1 + index))
    }
}

public extension View {

    func pinned(index: Int) -> some View {
        modifier(PinnedModifier(index: index))
    }
    
    func pinContainer() -> some View {
        self.coordinateSpace(name: Constants.coordinateSpace)
    }
}
