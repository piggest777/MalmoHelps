//
//  AddPersonViewModel 2.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-13.
//

import SwiftUI
import FirebaseCore
import Firebase
import Combine
import Foundation

class AddPersonValidatorViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertText: String = ""
    @Published var isLoading: Bool = false
    @Published var showPNAlert = false
    
    var isPresented: Binding<Bool>
    
    init(isPresented: Binding<Bool>) {
        self.isPresented = isPresented
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let service: FsService = FsService.shared
    
    func validatePersonalInfo(personalInfo: PersonalInfo) -> Bool {
        if personalInfo.firstName.isEmpty || personalInfo.lastName.isEmpty || personalInfo.phoneNumber.isEmpty {
            showAlert = true
            alertText = "Please fill all required fields."
            return false
        }
        
        // Check if the phone number is valid using a regular expression
        if !isValidPhoneNumber(personalInfo.phoneNumber) {
            showAlert = true
            alertText = "Please enter a valid phone number."
            return false
        }
        
        return true
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Regular expression for a valid phone number
        // Allows digits, spaces, dashes, and a leading plus sign
        let phoneRegex = "^[+]?[0-9]{7,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    func validateLocationInfo(locationInfo: LocationInfo) -> Bool {
        if locationInfo.city.isUndefined || locationInfo.city.region.isEmpty {
            showAlert = true
            alertText = "Please fill all required fields."
            return false
        }
        return true
    }
    
    func validateDocumentInfo(personalInfo: PersonalInfo) -> Bool {
        // Validate document type (cannot be undefined)
        if personalInfo.documentType == .undefined {
            showAlert = true
            alertText = "Please select a document type."
            return false
        }

        // If document type is "no docs", it's OK if no personal number is provided
        if personalInfo.documentType == .noDocs {
            return true
        }

        // Validate personal number (required for other document types)
        if personalInfo.personalNumber.isEmpty {
            showAlert = true
            alertText = "Please provide a document number."
            return false
        }
        
        // Validate document number based on the selected document type
        if !isValidDocumentNumber(personalInfo.personalNumber, for: personalInfo.documentType) {
            showAlert = true
            alertText = "The document number is not valid for the selected document type."
            return false
        }

        // Validate gender (cannot be undefined)
        if personalInfo.gender == .undefined {
            showAlert = true
            alertText = "Please select a gender."
            return false
        }

        // Validate age group (cannot be undefined)
        if personalInfo.ageGroup == .undefined {
            showAlert = true
            alertText = "Please select an age group."
            return false
        }

        // If all validations pass, return true
        return true
    }
    
    private func isValidDocumentNumber(_ documentNumber: String, for documentType: DocumentType) -> Bool {
        switch documentType {
        case .swedishCitizenship, .swedishPersonnummer:
            // Swedish citizenship or personal number: Allow digits and dashes (e.g., "YYYYMMDD-XXXX")
            let swedishNumberRegex = "^[0-9]{6,8}[-]?[0-9]{4}$"
            let swedishNumberTest = NSPredicate(format: "SELF MATCHES %@", swedishNumberRegex)
            return swedishNumberTest.evaluate(with: documentNumber)
            
        case .massflyktdirektiv, .asylum:
            // Massflyktdirektiv or asylum: Allow alphanumeric and dashes
            let asylumRegex = "^[A-Za-z0-9-]+$"
            let asylumTest = NSPredicate(format: "SELF MATCHES %@", asylumRegex)
            return asylumTest.evaluate(with: documentNumber)
            
        case .noDocs:
            // No docs: No number required
            return true
            
        default:
            // Generic format: allow letters, digits, spaces, and dashes
            let genericRegex = "^[A-Za-z0-9- ]+$"
            let genericTest = NSPredicate(format: "SELF MATCHES %@", genericRegex)
            return genericTest.evaluate(with: documentNumber)
        }
    }

    
    // Handles saving the person
    func handlePersonSave(person: Person?, personalNumber: String, isPNAbsent: Bool, id: String, firstName: String, lastName: String, phoneNumber: String, abfRegion: String, city: String, gender: String, documentType: String, ageGroup: String, countryOfOrigin: String) {
        let keywords = createKeywordsArray(firstName: firstName, lastName: lastName)
        
        let startDate: Timestamp = person?.startDate ?? Timestamp()
        let pn = isPNAbsent ? "000000-0000" : personalNumber

        let newPerson = Person(
            id: id,
            firstName: firstName,
            lastName: lastName,
            startDate: startDate,
            finishDate: nil,
            personalNumber: pn,
            phoneNumber: phoneNumber,
            customQrCode: nil,
            keywords: keywords,
            abfRegion: abfRegion,
            city: city,
            gender: gender,
            documentType: documentType,
            ageGroup: ageGroup,
            countryOfOrigin: countryOfOrigin
        )
        
        if let person = person, person.id.isEmpty, !isPNAbsent {
            checkPNBeforeAdding(person: newPerson)
        } else {
            addPerson(newPerson)
        }
    }
    // Checks if the personal number already exists
    func checkPNBeforeAdding(person: Person) {
        service.checkIfPNEXist(pn: person.personalNumber)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error)")
                }
            }, receiveValue: { exists in
                if exists {
                    self.alertText = "This personal number already added. Are you sure you want to add this person?"
                    self.showPNAlert = true
                } else {
                    self.addPerson(person)
                }
            })
            .store(in: &cancellables)
    }

    // Adds the person to Firebase
    func addPerson(_ person: Person) {
        isLoading = true
        service.addNewPerson(person)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure = completion {
                    self.showAlert = true
                    self.alertText = "Error while adding person to the database"
                } else {
                    self.dismissView()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    // Creates keywords from first and last name for search purposes
    func createKeywordsArray(firstName: String, lastName: String) -> [String] {
        return Array(Set(firstName.generateStringSequence() + lastName.generateStringSequence()))
    }

    // Break validation into smaller methods
    private func validateFields(_ uiElements: [WideTextField]) -> Bool {
        if uiElements.contains(where: { !$0.fieldValidation }) {
            showAlert = true
            alertText = "Format doesn't satisfy requirements"
            return false
        }
        if uiElements.contains(where: { $0.placeholder == .required && $0.input.isEmpty }) {
            showAlert = true
            alertText = "Please fill all required fields"
            return false
        }
        return true
    }

    private func validatePersonalNumber(_ personalNumber: String, _ isPNAbsent: Bool, _ personalNumberValidator: Bool) -> Bool {
        if !isPNAbsent && (personalNumber.isEmpty || !personalNumberValidator) {
            showAlert = true
            alertText = "Please fill personal number"
            return false
        }
        return true
    }

    private func validateGenderAndCity(_ gender: Gender, _ city: String) -> Bool {
        if gender == .undefined || city.isEmpty {
            showAlert = true
            alertText = "Gender or city is undefined"
            return false
        }
        return true
    }
    
    private func dismissView() {
        isPresented.wrappedValue = false
    }
}
