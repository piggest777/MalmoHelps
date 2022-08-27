//
//  FamiliesLookupViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//



import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FamiliesLookupViewModel: ObservableObject {
    @Published var queryResultUsers  = [Family]()
    
    private let db = Firestore.firestore()
    
    init(){
        print("init")
    }
    
    func fetchUsers(with keyword: String) {
        db.collection(REF_FAMILIES).whereField(KEYWORDS, arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("No documents")
                return
            }
            
            for document in documents {
                 let data = document.data()
                let firstName = data[FIRST_NAME] as? String ?? ""
                let secondName = data[SECOND_NAME] as? String ?? ""
                let place = data[PLACE] as? String ?? ""
                let room = data[ROOM] as? String ?? ""
                let keywords = data[KEYWORDS] as? [String] ?? []
                let notes = data[NOTES] as? String ?? ""
                let familySize = data[FAMILY_SIZE] as? String ?? ""
                
                let newFamily = Family(place: place, room: room, firstName: firstName, secondName: secondName, memberCount: familySize, notes: notes, keywords: keywords)
                
                self.queryResultUsers.append(newFamily)
            }
        }
    }
}
