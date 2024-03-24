//
//  String+.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 27.12.2023.
//

import Foundation

extension String {

    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
