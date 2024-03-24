//
//  UniversalTagLine.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 18.12.2023.
//

import SwiftUI

struct UniversalTagLine: View {
    let onDelete: (Int) -> Void
    let tags: [UniversalTagProps]
    
    var body: some View {
        FlowLayout(alignment: .leading) {
            ForEach(tags, id: \.self) { tag in
                UniversalTagView(tagProps: tag)
                    .onTapGesture {
                        guard let index = tags.firstIndex(of: tag) else {
                            return
                        }
                        onDelete(index)
                    }
            }
        }
    }
}
