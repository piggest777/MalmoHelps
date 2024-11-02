//
//  Gender.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-18.
//

import Foundation

enum Gender: String, CaseIterable, DropdownData {
    
    case male = "Man"
    case female = "Kvinna"
    case undefined
    
    var description: String {
        return rawValue.isEmpty ? "Undefined" : rawValue
    }
    
    var isUndefined: Bool {
        return self == .undefined
    }
    
    static func gender(fromString stringGender: String?) -> Gender {
        if let stringGender {
            return Gender(rawValue: stringGender) ?? .undefined
        }
        return .undefined
    }
}
