//
//  PersonalInfoView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-13.
//

import SwiftUI

struct PersonalInfo {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var personalNumber: String
    var gender: Gender
    var documentType: DocumentType
    var ageGroup: AgeGroup
}


struct PersonalInfoView: View {
    @Binding var personalInfo: PersonalInfo
    @State var firstNameValidator: Bool = true
    @State var lastNameValidator: Bool = true
    @State var phoneNumberValidator: Bool = true
    
    var body: some View {
        VStack {
            WideTextField(title: "First Name", placeholder: .required, validatorType: .required, input: $personalInfo.firstName, fieldValidation: $firstNameValidator)
            WideTextField(title: "Last Name", placeholder: .required, validatorType: .required, input: $personalInfo.lastName, fieldValidation: $lastNameValidator)
            WideTextField(title: "Phone", placeholder: .required, validatorType: .mobilePhone, input: $personalInfo.phoneNumber, fieldValidation: $phoneNumberValidator)
        }
    }
}
