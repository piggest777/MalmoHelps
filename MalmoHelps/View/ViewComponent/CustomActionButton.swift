//
//  CustomActionButton.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-13.
//

import SwiftUI


struct CustomActionButton: View {
    var title: String
    @Binding var isLoading: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColor"))
                    .cornerRadius(12)
                    .padding()
            } else {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColor"))
                    .cornerRadius(12)
                    .padding()
            }
        }
        .disabled(isLoading)
    }
}
