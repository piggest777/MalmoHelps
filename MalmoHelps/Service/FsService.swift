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
        
        let dataDictionary = [
            FIRST_NAME : person.firstName,
            LAST_NAME : person.lastName,
            PERSONAL_NUMBER : person.personalNumber,
            PHONE_NUMBER : person.phoneNumber,
            START_DATE : Timestamp(),
            FINISH_DATE : FINISH_DATE as Any,
            CUSTOM_QR_CODE : person.customQrCode ?? "",
            KEYWORDS : person.keywords,
            REGION : person.abfRegion as Any,
            GENDER : person.gender as Any,
            CITY : person.city as Any,
            CREATED_BY: Auth.auth().currentUser?.displayName  as Any
        ]
        
        return Future<Void, Error> { promise in
            var docId = person.id
            if docId.isEmpty {
                let collectionReference = self.db.collection(PERSON_COLLECTION)
                let newDocumentReference = collectionReference.document()
                docId = newDocumentReference.documentID
            }
            self.db.collection(PERSON_COLLECTION).document(docId).setData(dataDictionary){ error in
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
                DEFAULT_DURATION : activity.defaultDuration as Any,
                ACTIVITY_TYPE : activity.activityType as Any,
                CREATED_BY: Auth.auth().currentUser?.displayName  as Any
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
                PARTICIPANT_ID : person.id,
                ACTIVITY_ID: activity.id as Any,
                YEAR : year,
                MONTH : month,
                DAY : day,
                TIMESTAMP : Timestamp(date: date),
                DURATION : activity.defaultDuration ?? 1.0,
                ACTIVITY_NAME: activity.activityName,
                PERSON_IN_CHARGE: activity.personInCharge as Any,
                VENUE: activity.venue as Any,
                CREATED_BY: Auth.auth().currentUser?.displayName  as Any
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
    
    func fetchParticipant(by uid: String) -> Future<Person, FirestoreError> {
        let collectionRef = db.collection(PERSON_COLLECTION)
        return Future<Person, FirestoreError> { promise in
            collectionRef.document(uid).getDocument { snapshot, error in
                if let error  {
                    print(error.localizedDescription)
                    promise(.failure(FirestoreError.snapshotError))
                } else {
                    guard let snapshot = snapshot else {
                        promise(.failure(FirestoreError.documentNotFound))
                        return
                    }
                    guard let participant = Person.fromDocument(snapshot) else  {
                        promise(.failure(FirestoreError.snapshotError))
                        return
                    }
                    promise(.success(participant))
                }
            }
            
        }
    }
    
    func removeParticipant(by uid: String, completionHandler: @escaping (Bool) -> Void ) {
        db.collection(PERSON_COLLECTION).document(uid).delete { error in
            if error == nil {
                completionHandler(true)
            }
            else {
                print("Fail during deleting person: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func getAllCategories(completionHandler: @escaping ([Category])->()) {
        
        var categories: [Category] = []
        db.collection(CATEGORIES)
            .order(by: CATEGORY_NAME, descending: false)
            .getDocuments { querySnapshot, error in
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
    
    private func fetchRegistrations(query: Query) -> Future<[Registration], Error> {
        return Future { promise in
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("Error while fetching activities participant: \(error)")
                    promise(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("Snapshot is nil")
                    promise(.failure(FirestoreError.snapshotError)) // Define FirestoreError.snapshotError
                    return
                }

                let registrations = snapshot.documents.compactMap { document in
                    try? document.data(as: Registration.self)
                }
                promise(.success(registrations))
            }
        }
    }
    
    func getActivitiesParticipantFor(month: Int, year: Int, activity: ActivityEntry) -> Future<[Registration], Error> {
        let query = db.collection(REGISTRATION_COLLECTION)
            .whereField(MONTH, isEqualTo: month)
            .whereField(YEAR, isEqualTo: year)
            .whereField(ACTIVITY_NAME, isEqualTo: activity.activityName)
        return fetchRegistrations(query: query)
    }
    
    func getActivitiesParticipantById(month: Int, year: Int, activityId: String) -> Future<[Registration], Error> {
        let query = db.collection(REGISTRATION_COLLECTION)
            .whereField(MONTH, isEqualTo: month)
            .whereField(YEAR, isEqualTo: year)
            .whereField(ACTIVITY_ID, isEqualTo: activityId)

        return fetchRegistrations(query: query)
    }
    
    func checkIfPNEXist(pn: String) -> Future<Bool, Error> {
        return Future { promise in
            let ref = self.db.collection(PERSON_COLLECTION)
                .whereField(PERSONAL_NUMBER, isEqualTo: pn)

            ref.getDocuments { (snapshot, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let snapshot = snapshot else {
                    promise(.failure(FirestoreError.snapshotError))
                    return
                }

                if snapshot.documents.count > 0 {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
    }

    
    ///User managment
    
    func getUser(uid: String) -> Future<User, Error>{
        return Future { promise in
            let docRequest = self.db.collection(USERS_COLLECTION).document(uid)
            docRequest.getDocument { snapshot, error in
                if let error {
                    
                    print("Error while fetch user: \(error)")
                    promise(.failure(FirestoreError.snapshotError))
                }
                
                if let snapshot  {
                    if let user = try? snapshot.data(as: User.self) {
                        promise(.success(user))
                    } else {
                        promise (.failure(FirestoreError.userNotFound))
                    }
                }
                else {
                    promise(.failure(FirestoreError.snapshotError))
                }
            }
        }
    }
    
    func createUser(uid: String, name: String, email: String, completion: @escaping (Bool, Error?) -> ()) {
        
        let ref = db.collection(USERS_COLLECTION).document(uid)
        
        let data = [
            USER_EMAIL : email,
            USER_NAME : name,
            ROLE : UNDEFINED
        ]
        
        ref.getDocument { document, error in
            if let document, document.exists {
                print("user already exists")
                completion(true, nil)
            } else {
                ref.setData(data, merge: false) { err in
                    if let err {
                        print("Error adding user: \(err)")
                        completion(false, err)
                    } else {
                        completion(true, nil)
                        print("Document successfully written!")
                    }
                    
                }
            }
        }
    }
    
    func deleteUserFromFirestore(uid: String?, completion: @escaping (Bool)->(Void))  {
        if let uid {
            let ref = db.collection(USERS_COLLECTION).document(uid)
            ref.delete { error in
                if error == nil {
                    print("User with UID: \(uid) was deleted")
                    self.deleteUser()
                    completion(true)
                    return
                }
                print("error while deleting user from firestore: \(String(describing: error))")
            }
        }
    }
    
    func deleteUser() {
        let user = Auth.auth().currentUser
        user?.delete()
    }
    
    ///City management

    func getCities() -> Future<[City], Error> {
        return Future<[City], Error> { promise in
            let ref = self.db.collection(CITY_COLLECTION)
            ref
                .order(by: CITY)
                .getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    if let cities = snapshot?.documents.compactMap({ try? $0.data(as: City.self) }) {
                        promise(.success(cities))
                    } else {
                        promise(.failure(FirestoreError.snapshotError))
                    }
                }
            }
        }
    }
    
    
    func createCity(city: City, completionHandler: @escaping (Result<Void, FirestoreError>) -> Void) {
        let data: [String: Any] = [
            CITY: city.city,
            REGION: city.region
        ]
        
        db.collection(CITY_COLLECTION).addDocument(data: data) { error in
            if let error = error {
                completionHandler(.failure(.addDocumentError(error)))
            } else {
                completionHandler(.success(()))
            }
        }
    }
}

enum FirestoreError: Error {
    case snapshotError
    case documentNotFound
    case userNotFound
    case failedCast
    case addDocumentError(Error)
    
    
    var description: String {
        switch self {
        case .snapshotError:
            return "Snapshot is nil"
        case .documentNotFound:
            return "Document is nil"
        case .userNotFound:
            return "User not found in database"
        case .failedCast:
            return "Data can't be readen"
        case .addDocumentError(let error):
            return "Document can't be created: \(error)"
        }
    }
}

class Categories: ObservableObject {
    @Published var categories: [Category] = []
}
