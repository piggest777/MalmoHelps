//
//  AddActivtiyViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-22.
//

import Foundation
import SwiftUI
import Combine

class AddActivityViewModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertText = ""
    @Published var isPresented = true
    @Published var buttonDisabled = false
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func addNewActivity(_ activity:ActivityEntry) {
        isLoading = true
        FsService.shared.addNewActivity(activity)
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
}
