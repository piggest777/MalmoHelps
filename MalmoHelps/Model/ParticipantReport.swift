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
    var region: String
    var city: String
    var gender: String
    
    init(participantId: String, participantName: String, participantSurname: String, totalHours: Double, personalNumber: String, region: String, city: String, gender: String) {
        self.participantId = participantId
        self.participantName = participantName
        self.participantSurname = participantSurname
        self.totalHours = totalHours
        self.personalNumber = personalNumber
        self.region = region
        self.city = city
        self.gender = gender
    }
    
    enum CodingKeys: String, CodingKey {
        case participantId
        case participantName = "first_name"
        case participantSurname = "second_name"
        case totalHours
        case personalNumber = "personal_number"
        case region
        case city
        case gender
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.participantId = try container.decode(String.self, forKey: .participantId)
        self.participantName = try container.decodeIfPresent(String.self, forKey: .participantName) ?? ""
        self.participantSurname = try container.decode(String.self, forKey: .participantSurname)
        self.totalHours = try container.decode(Double.self, forKey: .totalHours)
        self.personalNumber = try container.decode(String.self, forKey: .personalNumber)
        self.region = try container.decode(String.self, forKey: .region)
        self.city = try container.decode(String.self, forKey: .city)
        self.gender = try container.decode(String.self, forKey: .gender)
    }
}

extension ParticipantReport {
    func toCSV() -> String {
        return "\(participantId),\(participantName),\(participantSurname),\(totalHours),\(personalNumber),\(region),\(city),\(gender)"
    }
}
