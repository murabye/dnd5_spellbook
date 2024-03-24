//
//  UserDefaults+.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 04.03.2024.
//

import Foundation

extension UserDefaults {
    
    enum Constants {
        static var selectedId = "selectedId"
        static var selectedFilterName = "selectedFilterName"
    }
    
    var selectedId: String? {
        get {
            string(forKey: Constants.selectedId)
        }
        set {
            setValue(newValue, forKey: Constants.selectedId)
        }
    }
    
    var selectedFilterName: String? {
        get {
            string(forKey: Constants.selectedFilterName)
        }
        set {
            setValue(newValue, forKey: Constants.selectedFilterName)
        }
    }
}
