//
//  StandartButton.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-28.
//

import SwiftUI

struct StandardButton: View {
    var color: Color = Color("ButtonColor")
    var text: String
    var action: ()->Void
    var body: some View {
        Button(action: action) {
            Text(text.uppercased())
                .font(Font.headline.weight(.bold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(12)
                .padding(.horizontal, 10)
        }
    }
}

struct StandartButton_Previews: PreviewProvider {
    static var previews: some View {
        StandardButton(text: "Test"){
            print("nothing")
        }
    }
}

