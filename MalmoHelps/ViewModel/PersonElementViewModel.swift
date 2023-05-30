//
//  PersonElementViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-10.
//

import Foundation
import Combine

class PersonElementViewModel: ObservableObject {
    
    private var cancelables = Set<AnyCancellable>()
    
    func addParticipant(for person: Person, at date: Date, activity: ActivityEntry) {
        FsService.shared.addNewRegistration(for: person, at: date, activity: activity)
            .sink { error in
             print("Error while adding registration \(error)")
         } receiveValue: {  _ in }
            .store(in: &cancelables)
    }
    
}
