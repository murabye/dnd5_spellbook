//
//  CharacterUpdateService.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 09.04.2024.
//

import Foundation
import Combine

extension Notification.Name {
    static let characterUpdate = Notification.Name("CharacterUpdate")
}

final class CharacterUpdateService {

    static func send() {
        NotificationCenter.default.post(name: Notification.Name.characterUpdate, object: nil)
    }

    static func publisher() -> AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: Notification.Name.characterUpdate)
            .map { _ in return () }
            .eraseToAnyPublisher()
    }
}
