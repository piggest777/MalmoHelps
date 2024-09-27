//
//  Family.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import Foundation
import FirebaseFirestore

struct Family: Codable {
    var id = ""
    var place: String 
    var room: String?
    var firstName : String
    var lastName: String
    var memberCount: String
    var notes: String?
    var keywords: [String]
    var addingDate: Timestamp
    var issueDate: String
}


