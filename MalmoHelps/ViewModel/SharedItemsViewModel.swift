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
            db.collection(REF_FAMILIES).document(familyId).collection(REF_DISTRIBUTED).getDocuments { shapshot, err in
                guard let documents = shapshot?.documents, err == nil else {
                    print("No documents")
                    return
                }
                
                
                documents.forEach { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let category = data[CATEGORY_NAME] as? String
                    let distributionDate = data[DISTRIBUTION_DATE] as? Timestamp
                    let expiredDate = data[EXPIRED_DATE] as? Timestamp
                    
                    if let distDate = distributionDate?.dateValue(), let expDate = expiredDate?.dateValue(), let name = category {
                        switch listSize {
                        case .short:
                            if (expDate > Date()) {
                                let newItem = SharedItems(id: id, category: name, distributionDate: distDate, expiredDate: expDate)
                                self.itemList.append(newItem)
                            }
                        case .long:
                            let newItem = SharedItems(id: id, category: name, distributionDate: distDate, expiredDate: expDate)
                            self.itemList.append(newItem)

                        }
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
