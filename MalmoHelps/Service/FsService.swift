//
//  FsService.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import Foundation
import FirebaseFirestore


class FsService {
    
    static let shared = FsService()
    
    
    let db = Firestore.firestore()
    
    func addFamilyToDB(family: Family, completionHandler: @escaping (Bool) -> () ) {
        
        db.collection(REF_FAMILIES).document().setData([
        
            PLACE : family.place,
            ROOM : family.room ?? "",
            FIRST_NAME : family.firstName,
            SECOND_NAME : family.secondName,
            FAMILY_SIZE : family.memberCount,
            NOTES : family.notes ?? "",
            KEYWORDS : family.keywords

        ], merge: true) { err in
            if err != nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
            
        }
    }
    
}
