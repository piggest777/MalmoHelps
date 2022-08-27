//
//  ViewExt.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import SwiftUI


extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
    
    
    @ViewBuilder func visibility(_ visibility: ViewVisibility) -> some View {
      if visibility != .gone {
        if visibility == .visible {
          self
        } else {
          hidden()
        }
      }
    }
}


enum ViewVisibility: CaseIterable {
  case visible, // view is fully visible
       invisible, // view is hidden but takes up space
       gone // view is fully removed from the view hierarchy
}
