//
//  AddPersonViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-26.
//

import Foundation
import Combine

class AddPersonViewModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertText = ""
    @Published var isPresented = true
    @Published var buttonDisabled = false
    @Published var isLoading = false
    
    private var cansellables = Set<AnyCancellable>()
    
    func addPerson(_ person: Person) {
        isLoading = true
        FsService.shared.addNewPerson(person)
            .sink { completion in
                switch completion {
                case .failure:
                    self.showAlert = true
                    self.alertText = "Error while adding person to base"
                    self.isLoading = false
                case .finished:
                    self.isLoading = false
                    self.isPresented = false
                }
            } receiveValue: { _ in }
            .store(in: &cansellables)
    }
    
    func createKeywordsArray(firstName: String, lastName: String) -> [String] {
        var keywords = [String]()
        
        keywords.append(contentsOf: firstName.generateStringSequence())
        keywords.append(contentsOf: lastName.generateStringSequence())
        return keywords
    }
}
