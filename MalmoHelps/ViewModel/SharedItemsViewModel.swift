//
//  SharedItemsViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class SharedItemsViewModel: ObservableObject {
    
    @Published var itemList: [SharedItems] = []
    @Published var familyId: String = ""
    @Published var searching: Bool = false
    
    private let db = Firestore.firestore()
    
    func downloadSharedItems(listSize: ListSize) {
        searching = true
        if !familyId.isEmpty {
            db.collection(REF_FAMILIES).document(familyId).collection(SHARED_ITEMS).getDocuments { shapshot, err in
                guard let documents = shapshot?.documents, err == nil else {
                    print("No documents")
                    return
                }
                
                
                documents.forEach { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let category = data[CATEGORY] as? String ?? ""
                    let distributionDate = data[DISTRIBUTION_DATE] as? Timestamp
                    let duration = data[DURATION] as? Int ?? 0
                    
                    guard let date = distributionDate else {return}
                    let normalDate = date.dateValue()
                    
                    guard let expiredData = Calendar.current.date(byAdding: .day, value: duration, to: normalDate) else {return}
                    
                    switch listSize {
                    case .short:
                        if (expiredData > Date()) {
                            let newItem = SharedItems(id: id, category: category, distributionDate: date, duration: duration)
                            self.itemList.append(newItem)
                        }
                    case .long:
                        let newItem = SharedItems(id: id, category: category, distributionDate: date, duration: duration)
                        self.itemList.append(newItem)

                    }
                }
                
                
                
                
                
            }
        }
        
    }
    
    
}


enum ListSize{
    case short
    case long
}
