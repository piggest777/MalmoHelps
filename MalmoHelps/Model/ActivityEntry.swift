//
//  ActivityEntry.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-27.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

struct ActivityEntry: Hashable, Codable {
    
    @DocumentID var id: String?
    var activityName: String
    var venue: String?
    var personInCharge: String?
    var defaultDuration: Float?
    var activityType: Int
    
    init(id: String, activityName: String, venue: String?, personInCharge: String?, defaultDuration: Float? = 1.0, activityType: Int = 0) {
        self.id = id
        self.activityName = activityName
        self.venue = venue
        self.personInCharge = personInCharge
        self.defaultDuration = defaultDuration
        self.activityType = activityType
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case activityName = "activity_name"
        case venue
        case personInCharge = "person_in_charge"
        case defaultDuration = "default_duration"
        case activityType = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.activityName = try container.decode(String.self, forKey: .activityName)
        self.venue = try container.decodeIfPresent(String.self, forKey: .venue)
        self.personInCharge = try container.decodeIfPresent(String.self, forKey: .personInCharge)
        self.defaultDuration = try container.decodeIfPresent(Float.self, forKey: .defaultDuration)
        self.activityType = try container.decodeIfPresent(Int.self, forKey: .activityType) ?? 0
    }
}
