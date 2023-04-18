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

struct Registration: Codable {
    
    @DocumentID var id: String?
    var participantName: String
    var participantId: String
    var year: Int
    var month: Int
    var day: Int
    var duration: Float = 1.0
    var timestamp: Timestamp
    
    init(id: String = "", participantName: String, participantId: String, year: Int, month: Int, day: Int, duration: Float, timestamp: Timestamp) {
        self.id = id
        self.participantName = participantName
        self.participantId = participantId
        self.year = year
        self.month = month
        self.day = day
        self.duration = duration
        self.timestamp = timestamp
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
     }
    
    
    
}
