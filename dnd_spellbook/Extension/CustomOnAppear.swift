//
//  CustomOnAppear.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 11.04.2024.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func appearOnce(action: @escaping () -> ()) -> some View {
        self.modifier(CustomOnAppearModifier(action: action))
    }
}

fileprivate struct CustomOnAppearModifier: ViewModifier {
    
    let action: () -> ()
    @State private var triggered: Bool = false
    func body(content: Content) -> some View {
        content.onAppear {
            if !triggered {
                action()
                triggered = true
            }
        }
    }
}
