//
//  ViewModels.swift
//  dnd_spellbook
//
//  Created by Vladimir Petrov on 29.05.24.
//

import Foundation

struct FilterModel: Hashable, Identifiable {

  enum FilterType: Hashable {
    case plus
    case reset
    case fiter(_ filter: Filter)
  }

  let id: String

  let type: FilterType

  init(_ type: FilterType) {
    self.type = type
    switch type {
    case .plus:
      self.id = "plus"
    case .reset:
      self.id = "reset"
    case .fiter(let filter):
      self.id = filter.id
    }
  }
}
