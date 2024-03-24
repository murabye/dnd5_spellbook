//
//  TagCreationView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI
import MCEmojiPicker

struct TagCreationView: View {
    
    @State var text: String = ""
    @State var emoji: String = "🤠"
    @State var isPresented: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(emoji) {
                    isPresented.toggle()
                }.emojiPicker(
                    isPresented: $isPresented,
                    selectedEmoji: $emoji
                )
                .buttonStyle(.bordered)
                Spacer(minLength: 8)
                TextField("Название", text: $text, axis: .horizontal)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                print("done")
            } label: {
                Text("Принять")
                    .padding(2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    MainActor.assumeIsolated {
        TagCreationView()
    }
}
