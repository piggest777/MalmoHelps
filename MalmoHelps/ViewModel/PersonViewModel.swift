//
//  PersonViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-19.
//

import Foundation
import Combine

class PersonDetailsViewModel: ObservableObject {
    @Published var person: Person
    // Other properties and methods
    
    var cancellables = Set<AnyCancellable>()

    init(person: Person) {
        self.person = person
    }

//    func updateParticipant() {
//        FsService.shared.fetchParticipant(by: person.id)
//            // ... same as above
//            .store(in: &cancellables)
//    }
}
