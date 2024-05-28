//
//  MainViewFilterLayer.swift
//  dnd_spellbook
//
//  Created by Vladimir Petrov on 29.05.24.
//

import SwiftUI
import WaterfallGrid

struct MainViewFilterLayer: View {

  enum Constants {
    static let minHeight: CGFloat = 40
    static let maxHeight: CGFloat = 120
    static var limitHeight: CGFloat {
      (maxHeight - minHeight) / 2 + minHeight
    }
  }

  @State private var bottomSheetHeight: CGFloat = Constants.minHeight
  @State private var previousHeight: CGFloat = Constants.minHeight

  let filterModels: [FilterModel]
  let selectedFilter: Filter?
  @Binding var selectedFilterName: String?
  @Binding var navPath: NavigationPath

  let removeFilter: (Filter?) -> Void

  var body: some View {
    VStack {
      Spacer()
      VStack {
        HStack {
          Spacer()
          Capsule()
            .fill(Color.gray)
            .frame(width: 40, height: 6)
          Spacer()
        }
        filterBar
          .frame(height: bottomSheetHeight)
      }
      .padding(.top, 8)
      .background(Color.systemGroupedTableContent)
    }
    .gesture(
      DragGesture()
        .onChanged { value in
          let newHeight = previousHeight - value.translation.height
          if newHeight > Constants.minHeight && newHeight < Constants.maxHeight {
            bottomSheetHeight = newHeight
          } else if newHeight >= Constants.maxHeight {
            bottomSheetHeight = Constants.maxHeight
          } else {
            bottomSheetHeight = Constants.minHeight
          }
        }
        .onEnded { value in
          withAnimation(.default) {
            if bottomSheetHeight < Constants.limitHeight {
              bottomSheetHeight = Constants.minHeight
            } else {
              bottomSheetHeight = Constants.maxHeight
            }
          }
          previousHeight = bottomSheetHeight
        }
    )
  }

  var filterBar: some View {
    ScrollView(.horizontal) {
      flow
        .padding(.horizontal, 8)
    }
    .scrollIndicators(.never)
  }

  @ViewBuilder
  var flow: some View {
    WaterfallGrid(filterModels) { filterModel in
      FilterModelContainerView(
        model: filterModel,
        selectedFilter: selectedFilter,
        selectedFilterName: $selectedFilterName,
        navPath: $navPath,
        removeFilter: removeFilter
      )
    }
    .gridStyle(
      columns: bottomSheetHeight > Constants.limitHeight ? 3 : 1,
      animation: .spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.7)
    )
    .scrollOptions(direction: .horizontal)
    .onChange(of: bottomSheetHeight > Constants.limitHeight) { newValue in
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    .frame(height: Constants.maxHeight, alignment: .bottomLeading)
  }
}
