//
//  Gender.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-18.
//

import Foundation

enum Gender: String, DropdownEnum {
    
    case male = "Man"
    case female = "Kvinna"
    case undefined
    
    var description: String {
        self.rawValue
    }
    
    var undefined: Bool {
        if self == .undefined {
            return true
        }
        return false
    }
    
    static func gender(fromString stringGender: String?) -> Gender {
        if let stringGender {
            return Gender(rawValue: stringGender) ?? .undefined
        }
        return .undefined
    }
}
