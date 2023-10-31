//
//  ActivityType.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-25.
//

import Foundation

enum ActivityType: Int, CaseIterable {
    case undefined = 0
    case individualSupport = 1
    case health = 2
    case groupActivities = 3
    case studySupport = 4
    case studyVisit = 5
    case internship = 6
    case competenceDevelopment = 7
    
    static let names: [ActivityType: String] = [
        .undefined: "Odefinierad",
        .individualSupport: "Individuellt stöd",
        .health: "Friskvård, träning, hälsa",
        .groupActivities: "Gruppaktivitet",
        .studySupport: "Förberedelser till studier",
        .studyVisit: "Studiebesök",
        .internship: "Praktik",
        .competenceDevelopment: "Kompetensutveckling"
    ]
    
    var description: String {
        return ActivityType.names[self] ?? "Odefinierad"
    }
    
    static func getActivityTypeByID(_ id: Int) -> ActivityType {
        return ActivityType(rawValue: id) ?? .undefined
    }
}
