//
//  Background.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-13.
//

import SwiftUI

struct Background: View {
    var body: some View {
        Rectangle()
            .fill(Color("Background"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview { Background() }
