//
//  FamiliesLookupViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//



import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FamiliesLookupViewModel: ObservableObject {
    @Published var queryResultFamilies  = [Family]()
    @Published var searching: Bool = false
    @Published var queryResultPerson: [Person] = [
//        Person(firstName: "Denis", lastName: "Rakitin", startDate: Timestamp(), finishDate: nil, personalNumber: "", phoneNumber: "", customQrCode: nil, keywords: []),
//        Person(firstName: "Denis", lastName: "Rakitin", startDate: Timestamp(), finishDate: nil, personalNumber: "", phoneNumber: "", customQrCode: nil, keywords: [])
    ]
    var cancellables = Set<AnyCancellable>()
    
    private let db = Firestore.firestore()
    
    init(){
        print("init")
    }
    
    func fetchFamilies(with keyword: String) {
        searching = true
        db.collection(REF_FAMILIES).whereField(KEYWORDS, arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("No documents")
                return
            }
            
            for document in documents {
                 let data = document.data()
                let id = document.documentID
                let firstName = data[FIRST_NAME] as? String ?? ""
                let secondName = data[LAST_NAME] as? String ?? ""
                let place = data[PLACE] as? String ?? ""
                let room = data[ROOM] as? String ?? ""
                let keywords = data[KEYWORDS] as? [String] ?? []
                let notes = data[NOTES] as? String ?? ""
                let familySize = data[FAMILY_SIZE] as? String ?? ""
                let addingDate = data[ADDING_DATE] as? Timestamp ?? Timestamp()
                
                let newFamily = Family(id: id, place: place, room: room, firstName: firstName, lastName: secondName, memberCount: familySize, notes: notes, keywords: keywords, addingDate: addingDate)
               
                if !self.queryResultFamilies.contains( where: { $0.id == id}) {
                    self.queryResultFamilies.append(newFamily)
                }
            }
            self.searching = false
        }
    }
    
    func fetchParticipants(keywords: String) {
        searching = true
        FsService.shared.fetchParticipants(with: keywords)
            .sink { error in
                print("Error while fetching participants: \(error)")
            } receiveValue: { participants in
                self.queryResultPerson = participants
                self.searching = false
            }.store(in: &cancellables)
        
    }
}

protocol FirebaseDocument {
    var id: String { get set }
}
