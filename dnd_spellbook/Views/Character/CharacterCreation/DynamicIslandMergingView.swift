//
//  DynamicIslandMergingView.swift
//  UULA
//
//  Created by Vladimir Petrov on 27/09/2023.
//  Copyright © 2023 UULA Technologies. All rights reserved.
//

import SwiftUI

extension View {
    ///  You need set anchor reference with the same key like this:
    ///  view.anchorPreference(key: AnchorKey.self, value: .bounds) {
    ///    ["key": $0]
    ///  }
    func mergingDynamicIslandWithView(
        forKey key: String,
        safeArea: EdgeInsets,
        backgroundColor: Color
    ) -> some View {
        backgroundPreferenceValue(AnchorKey.self) { preferences in
            DynamicIslandMergingView(
                preferences: preferences,
                safeArea: safeArea,
                itemKey: key,
                backgroundColor: backgroundColor
            )
        }
    }
}

struct AnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
    
}

struct DynamicIslandMergingView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let dynamicIslandWidth: CGFloat = 120
        static let spaceBetweenIslandAndTop: CGFloat = 11
        static let islandHeight: CGFloat = 37
    }
    
    // MARK: - Public Properties
    
    let preferences: [String: Anchor<CGRect>]
    let safeArea: EdgeInsets
    let itemKey: String
    let backgroundColor: Color
    
    // MARK: - Computed Properties
    
    private var isHavingNotch: Bool {
        safeArea.bottom != 0
    }
    
    private var shouldHideToIsland: Bool {
        UIDevice.current.userInterfaceIdiom != .pad && UIDevice.current.userInterfaceIdiom != .mac
    }
    
    private var isHaveDynamicIsland: Bool {
        safeArea.top > 51
    }
    
    private var capsuleHeight: CGFloat {
        isHaveDynamicIsland ? Constants.islandHeight : (safeArea.top - 15)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if shouldHideToIsland {
                dynamicIslandDrawer
                VStack {
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(height: 15)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var dynamicIslandDrawer: some View {
        if let anchor = preferences[itemKey], #available(iOS 15.0, *), isHavingNotch {
            GeometryReader { proxy in
                let frameRect = proxy[anchor]
                Canvas(
                    renderer: { out, _ in
                        dynamicIslandRenderer(out: &out, frameRect: frameRect, size: proxy.size)
                    },
                    symbols: { dynamicIslandSymbols(frameRect: frameRect) }
                )
            }
        }
    }
    
    @available(iOS 15.0, *)
    private func dynamicIslandRenderer(out: inout GraphicsContext, frameRect: CGRect, size: CGSize) {
        out.addFilter(.alphaThreshold(min: 0.5))
        out.addFilter(.blur(radius: 12))
        out.drawLayer { ctx in
            if let headerView = out.resolveSymbol(id: 0) {
                ctx.draw(headerView, in: frameRect)
            }
            if let dynamicIsland = out.resolveSymbol(id: 1) {
                let rect = CGRect(
                    x: (size.width - Constants.dynamicIslandWidth) / 2,
                    y: isHaveDynamicIsland ? Constants.spaceBetweenIslandAndTop : 0,
                    width: Constants.dynamicIslandWidth,
                    height: capsuleHeight
                )
                ctx.draw(dynamicIsland, in: rect)
            }
        }
    }
    
    @ViewBuilder
    private func dynamicIslandSymbols(frameRect: CGRect) -> some View {
        Group {
            headerView(frameRect)
                .tag(0)
                .id(0)
            dynamicIslandCapsule(capsuleHeight)
                .tag(1)
                .id(1)
        }
    }
    
    private func headerView(_ frameRect: CGRect) -> some View {
        Circle()
            .fill(.black)
            .frame(width: frameRect.width, height: frameRect.height)
    }
    
    private func dynamicIslandCapsule(_ height: CGFloat) -> some View {
        Capsule()
            .fill(.black)
            .frame(width: Constants.dynamicIslandWidth, height: height)
    }
}
