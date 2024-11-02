//
//  AddPersonViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-26.
//

import Foundation
import Combine
import UIKit
import SwiftUICore

class AddPersonViewModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var showPNAlert = false
    @Published var alertTitle = ""
    @Published var alertText = ""
    @Published var isPresented = true
    @Published var buttonDisabled = false
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNavigationBar()
    }
    
    func setupNavigationBar () {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color("DarkShadow"))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .black
    }
    
    func checkPNBeforeAdding(person: Person) {
        FsService.shared.checkIfPNEXist(pn: person.personalNumber)
            .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break  // Completed without errors.
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }, receiveValue: { exists in
                    if exists {
                        print("Personal number exists!")
                        
                        self.alertText = "This personal number already added. Are you sure you want to add this person?"
                        self.showPNAlert = true
                    } else {
                        self.addPerson(person)
                    }
                })
                .store(in: &cancellables)

    }
    
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
            .store(in: &cancellables)
    }
    
    func createKeywordsArray(firstName: String, lastName: String) -> [String] {
        var keywords = [String]()
        
        keywords.append(contentsOf: firstName.generateStringSequence())
        keywords.append(contentsOf: lastName.generateStringSequence())
        return keywords
    }
}
