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
    @Published var groupedActivities: [ActivityGroup] = []
    @Published var errorText: String = ""
    @Published var finishedWithFailure = false
    @Published var cities: [City] = []
    @Published var favoriteActivities: [ActivityEntry] = []
    var activitiesDictionary = [String: ActivityEntry]()
    var cancellables = Set<AnyCancellable>()
    
    init(activities: [ActivityEntry] = []) {
        self.activities = activities
        getActivities()
        getCities()
    }
    
    func updateFavoriteActivities() {
        let favorites = StorageManager.favourites
        favoriteActivities = activities.filter { favorites.contains($0.id ?? "") }
    }
    
    func getActivities() {
        FsService.shared.getAllActivities()
            .sink(receiveCompletion: { error in },
                  receiveValue: { activities in
                self.activities = activities.filter{ $0.archive == false }
                self.groupActivities()
                self.updateFavoriteActivities()

            }).store(in: &cancellables)
    }
    
    func getCities(){
        FsService.shared.getCities()
            .sink { result in
                switch result {
                case .finished:
                    print("Finished getting cities")
                case .failure(let error):
                    print("Error while getting cities: \(error)" )
                }
            } receiveValue: { cities in
                self.cities = cities
            }.store(in: &cancellables)

    }
    
    func groupActivities() {
        let groups = Dictionary(grouping: activities, by: { $0.activityType })
        groupedActivities = groups.map { (key, value) in
            ActivityGroup(type: ActivityType.getActivityTypeByID(key), activities: value, isExpanded: false)
        }.sorted(by: { $0.type.rawValue < $1.type.rawValue })
        
        
        
        activitiesDictionary = activities.reduce(into: [String: ActivityEntry]()) { (result, element) in
            if let id = element.id {
                result[id] = element
            }
        }
    }
    
    func toggleGroup(_ type: ActivityType) {
        if let index = groupedActivities.firstIndex(where: { $0.type == type }) {
            groupedActivities[index].isExpanded.toggle()
        }
    }
}
