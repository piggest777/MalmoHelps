//
//  ActivityEntry.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-27.
//

import Foundation

struct ActivityEntry: Hashable, Codable {
    var activityName: String
    var venue: String?
    var personInCharge: String?
    
    init(activityName: String, venue: String?, personInCharge: String?) {
        self.activityName = activityName
        self.venue = venue
        self.personInCharge = personInCharge
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(venue)
    }
    
    static func == (lhs: ActivityEntry, rhs: ActivityEntry) -> Bool {
        lhs.activityName == rhs.activityName
    }
    
    enum CodingKeys: String, CodingKey {
        case activityName = "activity_name"
        case venue
        case personInCharge = "person_in_charge"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.activityName = try container.decode(String.self, forKey: .activityName)
        self.venue = try container.decodeIfPresent(String.self, forKey: .venue)
        self.personInCharge = try container.decodeIfPresent(String.self, forKey: .personInCharge)
    }
}
