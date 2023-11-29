//
//  IconButton.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-19.
//

import SwiftUI

    struct IconButton: View {
        let iconName: String
        let text: String
        var isDestractive = false
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack {
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(isDestractive ? .red : .black)
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }.frame(width: 50)
        }
    }

#Preview {
    IconButton(iconName: "person.text.rectangle", text: "Edit", action: {})
}
