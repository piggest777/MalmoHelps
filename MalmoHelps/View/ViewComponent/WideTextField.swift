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
    case float
    case none
}

struct WideTextField: View, Hashable {
    let title: String
    let placeholder: FieldSRequest
    @State var validatorType: ValidatorType
    let isToggleEnabled: Bool
    let toggleText: String
    @Binding var input: String
    @State var backgroundColor: Color = Color(.white)
    @Binding var fieldValidation: Bool
    @Binding var isAbsent: Bool
    
    
    init(title: String, placeholder: FieldSRequest, validatorType: ValidatorType, input: Binding<String>, fieldValidation: Binding<Bool>, isToggleEnabled: Bool = false, isAbsent: Binding<Bool> = .constant(false), toggleText: String = "") {
        self.title = title
        self.placeholder = placeholder
        self.validatorType = validatorType
        self.isToggleEnabled = isToggleEnabled
        self.toggleText = toggleText
        self._fieldValidation = fieldValidation
        self._input = input
        self._isAbsent = isAbsent
    }
    
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
        case .float:
            return .numbersAndPunctuation
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
            ZStack {
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
                if isToggleEnabled && isAbsent {
                    Rectangle()
                        .frame(height: 70)
                    .foregroundColor(Color.black.opacity(0.2))
                }
            }
        }.onChange(of: isAbsent) { newValue in
            if newValue  {
                validatorType = .none
            }
        }
        if isToggleEnabled {
            HStack {
                Spacer()
                Toggle(isOn: $isAbsent) {
                    Text("\(title) can't be provided")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }.padding(.horizontal, 10)
            }
        }
    }
    
    private func validateMobilePhone(_ mobilePhone: String) {
        let mobilePhonePredicate = NSPredicate(format:"SELF MATCHES %@", mobilePhoneRegex)
        fieldValidation = mobilePhonePredicate.evaluate(with: mobilePhone)
    }
    
    private func validateLMANumber(_ number: String) {
        let lmaNumberPredicate = NSPredicate(format:"SELF MATCHES %@", lmaNumberRegex)
        fieldValidation = lmaNumberPredicate.evaluate(with: number)
        print(fieldValidation)
    }
    
    private func validateFloat(_ duration: String) {
        if (Float(duration) != nil) {
            fieldValidation = true
        } else {
            fieldValidation = false
        }
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
        case .float:
            validateFloat(input)
        }
    }
}

#Preview {
    WideTextField(title: "Name", placeholder: .required, validatorType: .required, input: .constant("Denis"), fieldValidation: .constant(false), isToggleEnabled: true, isAbsent: .constant(false))
}

#Preview {
    WideTextField(title: "Name", placeholder: .required, validatorType: .required, input: .constant("Denis"), fieldValidation: .constant(false), isToggleEnabled: true, isAbsent: .constant(true))
}
