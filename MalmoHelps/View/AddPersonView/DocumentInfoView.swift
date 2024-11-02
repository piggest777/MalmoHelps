//
//  DocumentInfoView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-14.
//

import SwiftUI

struct DocumentInfoView: View {
    @Binding var personalInfo: PersonalInfo
    @State var personalNumberValidator: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            WideTextField(title: "Document number", placeholder: .required, validatorType: .number, input: $personalInfo.personalNumber, fieldValidation: $personalNumberValidator)
            
            Menu {
                ForEach(DocumentType.allCases, id: \.self) { type in
                    Button(type.rawValue) {
                        personalInfo.documentType = type                    }
                }
            } label: {
                DropdownMenu<DocumentType>(menuName: "Document Type", value: $personalInfo.documentType, placeholder: "Choose document type")
            }
            
            Menu {
                ForEach(Gender.allCases.filter { $0 != .undefined }, id: \.self) { type in
                    Button(type.rawValue.capitalized) {
                        personalInfo.gender = type
                    }
                }
            } label: {
                DropdownMenu<Gender>(menuName: "Gender", value: $personalInfo.gender, placeholder: "Choose gender")
            }
            
            Menu {
                ForEach(AgeGroup.allCases.filter { $0 != .undefined }, id: \.self) { ageGroup in
                    Button(ageGroup.rawValue) {
                        personalInfo.ageGroup = ageGroup
                    }
                }
            } label: {
                DropdownMenu<AgeGroup>(menuName: "Age Group", value: $personalInfo.ageGroup, placeholder: "Choose age group")
            }
        }
        .padding()
    }
}
