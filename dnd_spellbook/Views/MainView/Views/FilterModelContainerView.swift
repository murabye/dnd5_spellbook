//
//  FilterModelContainerView.swift
//  dnd_spellbook
//
//  Created by Vladimir Petrov on 29.05.24.
//

import SwiftUI

struct FilterModelContainerView: View {

  let model: FilterModel
  let selectedFilter: Filter?
  @Binding var selectedFilterName: String?
  @Binding var navPath: NavigationPath

  let removeFilter: (Filter?) -> Void

  var body: some View {
    switch model.type {
    case .plus:
      UniversalTagView(
        tagProps: UniversalTagProps(
          title: "+",
          isActive: selectedFilter == nil,
          foregroundColor: .white,
          backgroundColor: selectedFilter == nil ? .blue : .gray,
          isActionable: false
        )
      )
      .onTapGesture {
        navPath.append(NavWay.filterCreate)
      }

    case .reset:
      UniversalTagView(
        tagProps: UniversalTagProps(
          title: "Без фильтра",
          isActive: selectedFilterName == nil || selectedFilterName == "",
          foregroundColor: .white,
          backgroundColor: selectedFilterName == nil || selectedFilterName == "" ? .blue : .gray,
          isActionable: false
        )
      )
      .onTapGesture {
        selectedFilterName = ""
      }

    case .fiter(let filter):
      UniversalTagView(
        tagProps: UniversalTagProps(
          title: filter.name,
          isActive: filter.name == selectedFilterName,
          foregroundColor: .white,
          backgroundColor: filter.name == selectedFilterName ? .blue : .gray,
          isActionable: false
        )
      )
      .onTapGesture {
        selectedFilterName = filter.name
      }
      .contextMenu {
        Button("Удалить", role: .destructive, action: { [weak filter] in removeFilter(filter) })
      }
    }
  }
}
