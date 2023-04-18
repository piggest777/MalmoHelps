//
//  AsyncButton.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-25.
//

import Foundation
import SwiftUI

struct AsyncButton: View {
    let text: String
    var color: Color = Color("ButtonColor")
    let action: () async -> Void
    @State private var isLoading = false
    
    var body: some View {
        Button(action: {
            isLoading = true
            Task {
                await action()
                isLoading = false
            }
        }) {
            if isLoading {
                ProgressView()
            } else {
                Text(text.uppercased())
                    .font(Font.headline.weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(color)
                    .cornerRadius(12)
                    .padding()
            }
        }.disabled(isLoading)
    }
}
