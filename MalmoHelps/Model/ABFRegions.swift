//
//  ABFRegions.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-15.
//

import Foundation

enum ABFRegions: String, CaseIterable, DropdownData {
    var description: String {
        self.rawValue
    }
    
    case malmo = "ABF Malmö"
    case sydvastra = "ABF Sydvästra Skåne"
    case nordvast = "ABF Nordvästskåne"
    case nordost = "ABF Skåne Nordost"
    case undefined = "Odefinierad"
    
    var isUndefined: Bool {
        get {
            if self == .undefined {
                return true
            }
            return false
        }
    }
    
    static func abfRegion(fromString region: String?) -> ABFRegions {
        if let region {
            return ABFRegions(rawValue: region) ?? .undefined
        }
        return .undefined
    }
}
