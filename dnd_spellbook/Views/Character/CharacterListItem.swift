//
//  CharacterListItem.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 21.12.2023.
//

import SwiftUI

struct CharacterListItem: View {
    let character: CharacterModel?
    let isCompact: Bool
    @AppStorage(UserDefaults.Constants.selectedId) var selectedId: String?
    var isSelected: Bool {
        character?.id != nil && selectedId == character?.id
    }
    
    init(character: CharacterModel?, isCompact: Bool) {
        self.character = character
        self.isCompact = isCompact
    }

    var body: some View {
        VStack(alignment: .center) {
            image
                .frame(
                    width: isCompact ? 30 : 70,
                    height: isCompact ? 30 : 70
                )
                .foregroundStyle(isSelected ? Color.blue : Color.inverted.opacity(0.6))
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Circle())
                .overlay(Circle().stroke(
                    isSelected ? Color.blue : Color.inverted.opacity(0.6),
                    lineWidth: isCompact ? 2 : 4
                ))
            
            if let name = character?.name, !isCompact {
                Text(name)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 120)
                    .foregroundStyle(isSelected ? Color.blue : Color.inverted.opacity(0.6))
            }
            Spacer(minLength: 0)
        }
    }
    
    private var image: some View {
        Group {
            if let url = character?.imageUrl {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    alternativeImage
                }
            } else {
                alternativeImage
            }
        }
    }
    
    private var alternativeImage: some View {
        Image(systemName: "person.fill")
            .resizable()
            .padding(isCompact ? 6 : 16)
    }
}

struct CharacterListAppendItem: View {
    let isSingle: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            image
                .frame(
                    width: 70,
                    height: 70
                )
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Circle())
                .overlay(Circle().stroke(
                    isSingle ? Color.blue : Color.inverted.opacity(0.7),
                    lineWidth: 4
                ))
            
            Text("Добавить")
                .fontWeight(.semibold)
                .foregroundStyle(isSingle ? Color.blue : Color.inverted.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 120)
            
            Spacer(minLength: 0)
        }
    }
    
    private var image: some View {
        Image(systemName: "person.badge.plus")
            .resizable()
            .foregroundStyle(isSingle ? Color.blue : Color.inverted.opacity(0.7))
            .padding(.top, 18)
            .padding(.bottom, 14)
            .padding(.leading, 20)
            .padding(.trailing, 12)
    }
}

#Preview {
    HStack(alignment: .center) {
        CharacterListAppendItem(isSingle: false)
        Spacer()
        CharacterListItem(
            character: CharacterModel(
                id: "1",
                imageUrl: nil,
                characterClass: .cleric,
                name: "Кронк",
                tagActions: [:],
                knownSpells: [],
                preparedSpells: []
            ),
            isCompact: true
        )
        Spacer()
    }
}
