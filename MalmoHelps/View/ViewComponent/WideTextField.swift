//
//  WideTextField.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-23.
//

import SwiftUI

enum ValidatorType {
    case number
    case mobilePhone
    case required
    case none
}

struct WideTextField: View, Hashable {
    let title: String
    let placeholder: FieldSRequest
    let validatorType: ValidatorType
    @Binding  var input: String
    @State var backgroundColor: Color = Color(.white)
    @Binding var fieldValidation: Bool
    
    private let mobilePhoneRegex: String  = "^[0-9+]{0,1}+[0-9]{5,16}$"
    private let lmaNumberRegex: String = "^[0-9-]*$"
    
    var keyboardType: UIKeyboardType {
        switch validatorType {
        case .number:
            return .numbersAndPunctuation
        case .mobilePhone:
            return .numbersAndPunctuation
        case .required:
            return .default
        case .none:
            return .default
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: WideTextField, rhs: WideTextField) -> Bool {
        lhs.title == rhs.title
    }
    
    var body: some View {
        
        VStack {
            Divider()
                .overlay(.black)
            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .font(.system(size: 16, weight: .bold, design: .default))
                TextField(placeholder.rawValue, text: $input, onEditingChanged: { changed in
                    if changed {
                        fieldValidation = true
                        backgroundColor = .white
                    } else {
                        validator()
                    }
                })
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .padding(.trailing)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .onSubmit {
                        validator()
                    }
                    .onChange(of: fieldValidation) { value in
                        if value {
                            backgroundColor = .white
                        } else {
                            backgroundColor = Color("RequiredColor")
                        }
                    }
                    .keyboardType(keyboardType)
            }
            .frame(height: 50)
            Divider()
                .overlay(.black)
        }
        .background(backgroundColor)
    }
    private func validateMobilePhone(_ mobilePhone: String) {
        let mobilePhonePredicate = NSPredicate(format:"SELF MATCHES %@", mobilePhoneRegex)
        fieldValidation = mobilePhonePredicate.evaluate(with: mobilePhone)
    }
    
    private func validateLMANumber(_ number: String) {
        let lmaNumberPredicate = NSPredicate(format:"SELF MATCHES %@", lmaNumberRegex)
        fieldValidation = lmaNumberPredicate.evaluate(with: number)
        
    }
    
    private func validator() {
        switch validatorType {
        case .number:
            validateLMANumber(input)
        case .mobilePhone:
            validateMobilePhone(input)
        case .required:
            fieldValidation = !input.isEmpty
        case .none:
            fieldValidation = true
        }
    }
}

struct WideTextField_Previews: PreviewProvider {
    static var previews: some View {
        WideTextField(title: "Name", placeholder: .required, validatorType: .none, input: .constant(""), fieldValidation: .constant(true))
        WideTextField(title: "Name", placeholder: .optional, validatorType: .none, input: .constant("Denis"), fieldValidation: .constant(true))
    }
}
