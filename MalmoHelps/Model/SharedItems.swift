//
//  sharedItems.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import Foundation
import FirebaseFirestore

struct SharedItems {
    var id = ""
    var category: String
    var distributionDate: Date
    var expiredDate: Date
}
