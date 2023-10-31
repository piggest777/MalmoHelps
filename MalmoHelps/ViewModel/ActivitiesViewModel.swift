//
//  ActivitiesViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-27.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseFunctions


class ActivitiesViewModel: ObservableObject {
    @Published var activities: [ActivityEntry]
    @Published var errorText: String = ""
    @Published var finishedWithFailure = false
    var cancellable: AnyCancellable? = nil
    
    init(activities: [ActivityEntry] = []) {
        self.activities = activities
        getActivities()
    }
    
    func getActivities() {
        cancellable = FsService.shared.getAllActivities()
            .sink(receiveCompletion: { error in },
                  receiveValue: { activities in
                self.activities = activities
            })
    }
}
