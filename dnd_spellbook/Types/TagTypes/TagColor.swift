//
//  TagColor.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 09.02.2024.
//

import Foundation
import SwiftUI

enum TagColor: String, Codable, CaseIterable {
    case lightRed
    case lightOrange
    case lightYellow
    case lightGreen
    case lightCyan
    case lightBlue
    case darkBlue

    case red
    case orange
    case yellow
    case green
    case mint
    case cyan
    case blue
        
    case darkRed
    case darkOrange
    case darkYellow
    case darkMint
    case darkGreen
    case gray
    case inverted
    
    case darkPurple
    case purple
    case indigo
    case lightPurple
    case pink

    var backgroundColor: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .mint: .mint
        case .cyan: .cyan
        case .blue: .blue
        case .lightRed: .blend(color1: .red, intensity: 0.4, color2: .white)
        case .lightOrange: .blend(color1: .orange, intensity: 0.5, color2: .white)
        case .lightYellow: .blend(color1: .yellow, intensity: 0.3, color2: .white)
        case .lightGreen: .blend(color1: .green, intensity: 0.3, color2: .white)
        case .lightCyan: .blend(color1: .cyan, intensity: 0.3, color2: .white)
        case .lightBlue: .blend(color1: .blue, intensity: 0.3, color2: .white)
        case .darkBlue: .blend(color1: .blue, intensity: 0.6, color2: .black)
        case .darkRed: .blend(color1: .red, intensity: 0.6, color2: .black)
        case .pink: .blend(color1: .pink, intensity: 0.6, color2: .black)
        case .purple: .purple
        case .indigo: .blend(color1: .indigo, intensity: 0.6, color2: .white)
        case .gray: .blend(color1: .gray, intensity: 0.7, color2: .white)
        case .inverted: .inverted
        case .lightPurple: .blend(color1: .purple, intensity: 0.3, color2: .white)
        case .darkMint: .blend(color1: .mint, intensity: 0.6, color2: .black)
        case .darkOrange: .blend(color1: .orange, intensity: 0.6, color2: .black)
        case .darkYellow: .blend(color1: .yellow, intensity: 0.6, color2: .black)
        case .darkGreen: .blend(color1: .green, intensity: 0.6, color2: .black)
        case .darkPurple: .blend(color1: .purple, intensity: 0.6, color2: .black)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .yellow, .mint, .cyan, .lightRed,
                .lightOrange, .lightYellow, .lightGreen,
                .lightCyan, .lightBlue, .lightPurple: .black
        case .inverted: .themed
        default: .white
        }
    }
}


extension Color {
    static func blend(color1: Color, intensity: CGFloat = 0.5, color2: Color) -> Color {
        let intensity1 = intensity
        let intensity2 = 1 - intensity

        let color1comp = color1.resolve(in: EnvironmentValues())
        let color2comp = color2.resolve(in: EnvironmentValues())
        
        return Color(
            red: intensity1 * CGFloat(color1comp.red) + intensity2 * CGFloat(color2comp.red),
            green: intensity1 * CGFloat(color1comp.green) + intensity2 * CGFloat(color2comp.green),
            blue: intensity1 * CGFloat(color1comp.blue) + intensity2 * CGFloat(color1comp.blue),
            opacity: 1
        )
    }
}
