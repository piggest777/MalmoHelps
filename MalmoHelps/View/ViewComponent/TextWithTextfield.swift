//
//  TextWithTextfield.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import SwiftUI

struct TextWithTextfield: View {
    
    var textString: String
    @Binding var textBinding: String
    @Binding var editing: Bool
    var body: some View {
        Text(textString)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 16, weight: .bold, design: .default))
            .padding(2)
        TextField(textString, text: $textBinding, onEditingChanged: { edit in
            self.editing = edit
        })
        .textFieldStyle(MyTextFieldStyle(focused: $editing))
            .padding(.bottom)
    }
}

//struct TextWithTextfield_Previews: PreviewProvider {
//    static var previews: some View {
//        TextWithTextfield()
//    }
//}
