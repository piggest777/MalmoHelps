//
//  ActivityRapport.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-26.
//

import Foundation

struct ActivityReport: Codable {
    let activityId: String
    let activityName: String
    let personInCharge: String
    let venue: String
    let totalHours: Double
    let uniqueVisitorsCount: Int?
    
    init(activityId: String, activityName: String, personInCharge: String, venue: String, totalHours: Double, uniqueVisitorsCount: Int?) {
        self.activityId = activityId
        self.activityName = activityName
        self.personInCharge = personInCharge
        self.venue = venue
        self.totalHours = totalHours
        self.uniqueVisitorsCount = uniqueVisitorsCount
    }
    
    enum CodingKeys: String, CodingKey {
        case activityId
        case activityName
        case personInCharge
        case venue
        case totalHours
        case uniqueVisitorsCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.activityId = try container.decode(String.self, forKey: .activityId)
        self.activityName = try container.decode(String.self, forKey: .activityName)
        self.personInCharge = try container.decode(String.self, forKey: .personInCharge)
        self.venue = try container.decode(String.self, forKey: .venue)
        self.totalHours = try container.decode(Double.self, forKey: .totalHours)
        self.uniqueVisitorsCount = try container.decodeIfPresent( Int.self, forKey: .uniqueVisitorsCount)
    }
}

extension ActivityReport {
    func toCSV() -> String {
        return "\(activityId),\(activityName),\(personInCharge),\(venue),\(totalHours),\(uniqueVisitorsCount ?? 0)"
    }
}
