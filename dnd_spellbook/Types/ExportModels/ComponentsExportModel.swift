//
//  ComponentsExportModel.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 08.05.2024.
//

import Foundation

class ComponentsExportModel: Codable {
    
    let material: String
    let somatic: Bool
    let verbal: Bool
    let authorPay: Int

    init(components: ComponentsModel) {
        self.material = components.material
        self.somatic = components.somatic
        self.verbal = components.verbal
        self.authorPay = components.authorPay
    }
    
    var component: Component {
        if somatic {
            return .somatic
        } else if verbal {
            return .verbal
        } else if authorPay > 0 {
            return .authorPay(authorPay)
        } else {
            return .material(material)
        }
    }
}
