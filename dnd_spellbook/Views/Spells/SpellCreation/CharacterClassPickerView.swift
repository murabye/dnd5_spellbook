//
//  CharacterClassPickerView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 03.01.2024.
//

import SwiftUI

struct CharacterClassPickerView: View {
    @State var selectedClass: CharacterClass
    var classes: [CharacterClass]

    init(selectedClasses: [CharacterClass]) {
        let selectedSet = Set(selectedClasses)
        let allSet = Set(CharacterClass.allCases)
        let res = allSet.subtracting(selectedSet)
        let sorted = Array(res).sorted()
        self.classes = sorted
        self.selectedClass = sorted.middle ?? .cleric
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if classes.isEmpty {
                Text("Больше нечего добавить")
            } else {
                Picker("Класс", selection: $selectedClass) {
                    ForEach(classes, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(.wheel)
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
    ScrollView {
        VStack {
            CharacterClassPickerView(selectedClasses: [])
                .background(Color.white)
            
            CharacterClassPickerView(selectedClasses: CharacterClass.allCases)
                .background(Color.white)

            CharacterClassPickerView(selectedClasses: [.bard, .druid, .warlock])
                .background(Color.white)
        }
    }
    .background(Color.cyan)
}

extension Array {

    var middle: Element? {
        guard count != 0 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }
}
