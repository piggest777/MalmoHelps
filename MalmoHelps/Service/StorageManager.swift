//
//  StorageManager.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-26.
//

import Foundation

class StorageManager {
    
    static var favourites: Set<String> {
        get {
            let savedIDs = UserDefaults.standard.stringArray(forKey: FAVORITES_KEY) ?? []
            return Set(savedIDs)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: FAVORITES_KEY)
        }
    }
    
    static func updateFavorite(activityID: String, isFavorite: Bool) {
        if isFavorite {
            favourites.insert(activityID)
        } else {
            favourites.remove(activityID)
        }
    }
    
    static func isFav(activityId: String) -> Bool {
        return favourites.contains(activityId)
    }
}
