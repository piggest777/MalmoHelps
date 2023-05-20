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
    
    func addParticipant(for person: Person, at date: Date, with duration: Float, activityName: String, personInCharge: String?, venue: String?) {
        FsService.shared.addNewRegistration(for: person, at: date, with: duration, activityName: activityName, personInCharge: personInCharge, venue: venue)
            .sink { error in
             print("Error while adding registration \(error)")
         } receiveValue: {  _ in }
            .store(in: &cancelables)
    }
    
}
