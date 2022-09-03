//
//  StandartButton.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-28.
//

import SwiftUI

struct StandardtButton: View {
    var color: Color
    var text: String
    var action: ()->Void
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(12)
                .padding()
        }
    }
}

struct StandartButton_Previews: PreviewProvider {
    static var previews: some View {
        StandardtButton(color: Color((.systemMint)), text: "Test"){
            print("nothing")
        }
    }
}

