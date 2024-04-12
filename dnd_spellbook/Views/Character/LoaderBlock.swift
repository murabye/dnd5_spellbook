//
//  LoaderBlock.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 12.04.2024.
//

import Foundation
import SwiftUI

struct LoaderBlock: View {
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        .controlSize(.extraLarge)
                        .padding(.all, 24)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("Загрузка будет долгой")
                    Text("нам нужно подготовить")
                    Text("все заклинания класса")
                }
                Spacer()
            }
            Spacer()
        }
    }
}
