//
//  FsService.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import Combine


class FsService {
    
    static let shared = FsService()
    
    
    let db = Firestore.firestore()
    
    func addFamilyToDB(family: Family, completionHandler: @escaping (Bool) -> () ) {
        
        db.collection(REF_FAMILIES).document().setData([
            PLACE : family.place,
            ROOM : family.room ?? "",
            FIRST_NAME : family.firstName,
            LAST_NAME : family.lastName,
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
            LAST_NAME : family.lastName,
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
    
    func deleteFamily(familyId: String, completionHandler: @escaping (Bool)->()) {
        db.collection(REF_FAMILIES).document(familyId).delete(){
            err in
            if let err = err {
                print("Error removing document: \(err)")
                completionHandler(false)
            } else {
                print("Document successfully removed!")
                completionHandler(true)
            }
        }
    }
    
    func addNewPerson(_ person: Person) -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection(PERSON_COLLECTION).addDocument(data: [
                FIRST_NAME : person.firstName,
                LAST_NAME : person.lastName,
                PERSONAL_NUMBER : person.personalNumber,
                PHONE_NUMBER : person.phoneNumber,
                START_DATE : Timestamp(),
                FINISH_DATE : FINISH_DATE,
                CUSTOM_QR_CODE : person.customQrCode ?? "",
                KEYWORDS : person.keywords
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    func addNewActivity(_ activity: ActivityEntry) -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection(ACTIVITY_COLLECTION).addDocument(data: [
                ACTIVITY_NAME : activity.activityName,
                PERSON_IN_CHARGE : activity.personInCharge as Any,
                VENUE : activity.venue as Any,
                DEFAULT_DURATION: activity.defaultDuration as Any
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    func addNewRegistration(for person: Person, at date: Date, activity: ActivityEntry) -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            self.db.collection(REGISTRATION_COLLECTION).addDocument(data: [
                PARTICIPANT_NAME : "\(person.firstName) \(person.lastName)",
                PARTICIPANT_ID :  person.id,
                YEAR : year,
                MONTH : month,
                DAY : day,
                TIMESTAMP : Timestamp(date: date),
                DURATION : activity.defaultDuration ?? 1.0,
                ACTIVITY_NAME: activity.activityName,
                PERSON_IN_CHARGE: activity.personInCharge as Any,
                VENUE: activity.venue as Any
            ]) { error in
                if let error {
                    promise(.failure(error))
                    print("error while adding registration document: \(error)")
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    
    func removeRegistration(for person: Registration) {
        guard let id = person.id else {return}
        db.collection(REGISTRATION_COLLECTION).document(id).delete()
        }
    
    func deleteDistCategory(familyId: String, distCatId: String) {
        db.collection(REF_FAMILIES).document(familyId).collection(REF_DISTRIBUTED).document(distCatId).delete(){
            err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func createUserWithLoginAndPass (login: String, password: String, completion handler: @escaping (Bool)->()) {
        Auth.auth().createUser(withEmail: login, password: password) { authResult, error in
            if error == nil {
                handler(true)
            } else {
                handler (false)
            }
        }
    }
    
    func authUserWithLoginAndPass (login: String, password: String, completion handler: @escaping (Bool)->()) {
        Auth.auth().signIn(withEmail: login, password: password) { authResult, error in
            if error == nil {
                handler(true)
            } else {
                handler (false)
            }
        }
    }
    
    func getAllActivities() -> Future<[ActivityEntry], Error> {
        let collectionRef = db.collection(ACTIVITY_COLLECTION)
        return Future<[ActivityEntry], Error> { promise in
            collectionRef
                .order(by: "activity_name", descending: false)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        guard let documents = snapshot?.documents else {
                            promise(.success([]))
                            return
                        }
                        let entries = documents.compactMap { document in
                            try? document.data(as: ActivityEntry.self)
                        }
                        promise(.success(entries))
                    }
                }
        }
    }
    
    func fetchParticipants(with keyword: String) -> Future<[Person], Error> {
        let collectionRef = db.collection(PERSON_COLLECTION)
        return Future<[Person], Error> { promise in
            collectionRef
                .whereField(KEYWORDS, arrayContains: keyword.lowercased())
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        guard let documents = snapshot?.documents else {
                            promise(.success([]))
                            return
                        }
                        let entries = documents.compactMap { document in
                            Person.fromDocument(document)
                        }
                        promise(.success(entries))
                    }
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
    
    func getAllParticipantActivities(for personId: String, month: Int, year: Int) -> Future<[Registration], Error> {
        return Future { promise in
            let query = self.db.collection(REGISTRATION_COLLECTION)
                .whereField(PARTICIPANT_ID, isEqualTo: personId)
                .whereField(MONTH, isEqualTo: month)
                .whereField(YEAR, isEqualTo: year)
                .order(by: TIMESTAMP, descending: false)

                query.getDocuments { snapshot, error in
                    if let error {
                        print("Error while fetching registration list for participant: \(error)")
                        promise(.failure(error))
                    } else if let snapshot {
                        let registrations = snapshot.documents.compactMap { document in
                            try? document.data(as: Registration.self)
                        }
                        promise(.success(registrations))
                    }
                }
        }
    }
}

class Categories: ObservableObject {
    @Published var categories: [Category] = []
}
