//
//  ActivityEntry.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-10-18.
//

import Foundation


struct ActivityVenue: Hashable {
    var venue: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(venue)
    }
    
    static func == (lhs: ActivityVenue, rhs: ActivityVenue) -> Bool {
        lhs.venue == rhs.venue
    }
}
