//
//  Registration.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-07.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

struct Registration: Codable, Identifiable, Hashable {
    
    @DocumentID var id: String?
    var participantName: String
    var participantId: String
    var year: Int
    var month: Int
    var day: Int
    var duration: Float = 1.0
    var timestamp: Timestamp
    var activityName: String
    var activityPersonInCharge: String?
    var venue: String?
    
    init(id: String = "", participantName: String, participantId: String, year: Int, month: Int, day: Int, duration: Float, timestamp: Timestamp, activityName: String, activityPersonInCharge: String?, venue: String?) {
        self.id = id
        self.participantName = participantName
        self.participantId = participantId
        self.year = year
        self.month = month
        self.day = day
        self.duration = duration
        self.timestamp = timestamp
        self.activityName = activityName
        self.activityPersonInCharge = activityPersonInCharge
        self.venue = venue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.participantName = try container.decode(String.self, forKey: .participantName)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.year = try container.decode(Int.self, forKey: .year)
        self.month = try container.decode(Int.self, forKey: .month)
        self.day = try container.decode(Int.self, forKey: .day)
        self.duration = try container.decode(Float.self, forKey: .duration)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.activityName = try container.decode(String.self, forKey: .activityName)
        self.activityPersonInCharge = try container.decodeIfPresent(String.self, forKey: .activityPersonInCharge)
        self.venue = try container.decodeIfPresent(String.self, forKey: .venue)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case participantName = "participant_name"
        case participantId = "participant_id"
        case year
        case month
        case day
        case duration
        case timestamp
        case activityName = "activity_name"
        case activityPersonInCharge = "person_in_charge"
        case venue
    }
}
