//
//  ParticipantRaport.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-22.
//

import Foundation

struct ParticipantReport: Codable {
    var participantId: String
    var participantName: String
    var participantSurname: String
    var totalHours: Double
    var personalNumber: String
    
    init(participantId: String, participantName: String, participantSurname: String, totalHours: Double, personalNumber: String) {
        self.participantId = participantId
        self.participantName = participantName
        self.participantSurname = participantSurname
        self.totalHours = totalHours
        self.personalNumber = personalNumber
    }
    
    enum CodingKeys: String, CodingKey {
        case participantId
        case participantName = "first_name"
        case participantSurname = "second_name"
        case totalHours
        case personalNumber = "personal_number"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.participantName = try container.decode(String.self, forKey: .participantName)
        self.participantSurname = try container.decode(String.self, forKey: .participantSurname)
        self.totalHours = try container.decode(Double.self, forKey: .totalHours)
        self.personalNumber = try container.decode(String.self, forKey: .personalNumber)
    }
}

extension ParticipantReport {
    func toCSV() -> String {
        return "\(participantId),\(participantName),\(participantSurname),\(totalHours),\(personalNumber)"
    }
}
