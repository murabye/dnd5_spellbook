//
//  ShareActivityView.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}
}

struct ShareText: Identifiable {
    let id = UUID()
    let text: String
}
