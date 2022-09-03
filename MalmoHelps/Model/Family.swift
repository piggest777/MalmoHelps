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
    var secondName: String
    var memberCount: String
    var notes: String?
    var keywords: [String]
    var addingDate: Timestamp
    
//    init(place: String, room: String?, firstName: String, secondName: String, memberCount: String, notes: String?, keywords: [String]) {
//        self.place = place
//        self.room = room
//        self.firstName = firstName
//        self.secondName = secondName
//        self.memberCount = memberCount
//        self.notes = notes
//        self.keywords = keywords
//    }
    
}


