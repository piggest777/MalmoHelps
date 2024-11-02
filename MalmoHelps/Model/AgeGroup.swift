//
//  AgeGroup.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-14.
//


enum AgeGroup: String, CaseIterable, DropdownData {
    case zeroToFourteen = "0-14"
    case fourteenToTwentySeven = "14-27"
    case twentySevenToSixtyTwo = "27-62"
    case sixtyTwoPlus = "62+"
    case undefined
    
    var description: String {
        self.rawValue
    }
    
    var isUndefined: Bool {
        return self == .undefined
    }
    
    static func ageGroup(fromString string: String) -> AgeGroup {
        return AgeGroup(rawValue: string) ?? .undefined
    }
}
