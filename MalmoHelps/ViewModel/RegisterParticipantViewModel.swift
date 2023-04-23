//
//  RegisterParticipantViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-06.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Combine

class RegisterParticipantViewModel: ObservableObject {
    @Published var registeredParticipants: [Registration] = [
//        Registration(participantName: "Denis", participantId: "ffasdf", year: 2023, month: 4, day: 10, duration: 1.0, timestamp: Date())
    ]
    
    let registrationDay: Date
    private var db = Firestore.firestore()
    private var registrationListener: ListenerRegistration?
    private var year: Int
    private var month: Int
    private var day: Int
    private var startOfDay: Date
    private var endOfDay: Date
    private var cancellables = Set<AnyCancellable>()
    
    init(registrationDay: Date, activityName: String) {
        self.registrationDay = registrationDay
        let calendar = Calendar.current
                
        self.year = calendar.component(.year, from: registrationDay)
        self.month = calendar.component(.month, from: registrationDay)
        self.day = calendar.component(.day, from: registrationDay)
                
        self.startOfDay = calendar.startOfDay(for: registrationDay)
        self.endOfDay = calendar.date(byAdding: .day, value: 1, to: registrationDay)!
        fetchParticipantListFor(for: registrationDay, activityName: activityName)
    }
    deinit {
        registrationListener?.remove()
        cancellables.removeAll()
    }
    
    func fetchParticipantListFor(for date: Date, activityName: String) {
        let query = db.collection(REGISTRATION_COLLECTION)
              .whereField(YEAR, isEqualTo: year)
              .whereField(MONTH, isEqualTo: month)
              .whereField(DAY, isEqualTo: day)
              .whereField(ACTIVITY_NAME, isEqualTo: activityName)
              .whereField(TIMESTAMP, isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
              .whereField(TIMESTAMP, isLessThan: Timestamp(date: endOfDay))
        
        registrationListener = query.addSnapshotListener({ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching registration: \(error!)")
                return
            }
            self.registeredParticipants = documents.compactMap({ document -> Registration?  in
                try? document.data(as: Registration.self)
            })
            
        })
    }
    
    func addRegistration(for person: Person, duration: Float = 1.0, activityName: String, personInCharge: String?) {
        let newRegistration = FsService.shared.addNewRegistration(for: person, at: registrationDay, with: duration, activityName: activityName, personInCharge: personInCharge)
        newRegistration.sink { error in
            print("Error while registration \(error)")
        } receiveValue: {  _ in }
            .store(in: &cancellables)
    }
}
