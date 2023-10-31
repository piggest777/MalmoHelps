//
//  Person.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-25.
//

import Foundation
import FirebaseFirestore

struct Person {
    var id = ""
    let firstName: String
    let lastName: String
    let startDate: Timestamp
    let finishDate: Timestamp?
    let personalNumber: String
    let phoneNumber: String
    let customQrCode: String?
    let keywords: [String]
    let abfRegion: String?
    let city: String?
    
    static func fromDocument(_ document: DocumentSnapshot) -> Person? {
        guard let data = document.data(),
              let firstName = data[FIRST_NAME] as? String,
              let lastName = data[LAST_NAME] as? String,
              let startDate = data[START_DATE] as? Timestamp,
              let personalNumber = data[PERSONAL_NUMBER] as? String,
              let phoneNumber = data[PHONE_NUMBER] as? String,
              let keywords = data[KEYWORDS] as? [String]
        else { return nil }
        let id = document.documentID
        let customQrCode = data[CUSTOM_QR_CODE] as? String
        let finishDate = data[FINISH_DATE] as? Timestamp
        let abfRegion = data[ABF_REGION] as? String
        let city = data[CITY] as? String
        
        return Person(id: id, firstName: firstName, lastName: lastName, startDate: startDate, finishDate: finishDate, personalNumber: personalNumber, phoneNumber: phoneNumber, customQrCode: customQrCode, keywords: keywords, abfRegion: abfRegion, city: city)
    }
    }

