//
//  FsService.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import Foundation
import FirebaseFirestore
import SwiftUI


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
            KEYWORDS : family.keywords,
            ADDING_DATE : family.addingDate
            
        ], merge: true) { err in
            if err != nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
            
        }
    }
    
    func updateFamily(family: Family, completionHandler: @escaping (Bool) -> () ) {
        
        db.collection(REF_FAMILIES).document(family.id).setData([
            PLACE : family.place,
            ROOM : family.room ?? "",
            FIRST_NAME : family.firstName,
            SECOND_NAME : family.secondName,
            FAMILY_SIZE : family.memberCount,
            NOTES : family.notes ?? "",
            KEYWORDS : family.keywords,
            ADDING_DATE : family.addingDate
            
        ], merge: true) { err in
            if err != nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    func getAllCategories(completionHandler: @escaping ([Category])->()) {
        
        var categories: [Category] = []
        db.collection(CATEGORIES).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Failed to fetch docs: \(String(describing: error?.localizedDescription))")
                return
            }
            
            documents.forEach { document in
                let data = document.data()
                let id =  document.documentID
                let name = data[CATEGORY_NAME] as? String
                let duration = data[DURATION] as? Int
                
                if name != nil && duration != nil {
                    let newCat = Category(id: id, name: name!, durationInDays: duration!)
                    
                    categories.append(newCat)
                }
            }
            completionHandler(categories)
        }
        
    }
    
    
}

class Categories: ObservableObject {
    @Published var categories: [Category] = []
}
