//
//  CharacterImagePickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.03.2024.
//

import SwiftUI

struct CharacterImagePickerView: View {
    
    @Binding var isPickerSelected: Bool
    @Binding var selectedImage: UIImage?
    @Binding var scrollOffset: CGFloat

    private var imageSize: CGFloat? {
        70.0 - (30.0 * scrollProgress)
    }

    private var scrollProgress: CGFloat {
        let adjustedOffset = scrollOffset - 25
        return max(min(adjustedOffset / 25, 1), 0)
    }

    var body: some View {
        Button(action: {
            isPickerSelected = true
        }) {
            HStack {
                Spacer().frame(height: 100)
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .frame(width: imageSize, height: imageSize, alignment: .top)
                        .background()
                        .blur(radius: 10 * scrollProgress, opaque: true)
                        .opacity(1 - scrollProgress)
                        .clipShape(Circle())
                        .anchorPreference(key: AnchorKey.self, value: .bounds) {
                            [ CharacterCreationView.Constants.islandCollapsableItemKey: $0 ]
                        }
                } else {
                    Image("plus")
                        .resizable()
                        .frame(width: imageSize, height: imageSize, alignment: .top)
                        .background()
                        .blur(radius: 10 * scrollProgress, opaque: true)
                        .opacity(1 - scrollProgress)
                        .clipShape(Circle())
                        .anchorPreference(key: AnchorKey.self, value: .bounds) {
                            [ CharacterCreationView.Constants.islandCollapsableItemKey: $0 ]
                        }
                }
                Spacer().frame(height: 100)
            }
            .padding(.top, 10)
        }
    }
}
