//
//  DistributeViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-09-03.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class DistributeViewModel: ObservableObject {
    
    @AppStorage("distribution_place") var distPlace: String = ""
    @Published var distributed: Bool = false
    @Published var progressViewVisibility: ViewVisibility = .invisible
    @Published var distributedCategories: [Category] = []
    
    let db = Firestore.firestore()
    
    
    
    func addCategoriesToFamily (familyId: String, selectedCategories: [Category], completionHandler: @escaping (Bool)-> ()) {
        let batch = db.batch()
        let distributeDate = Date()
        let currentTimeStamp = Timestamp(date: distributeDate)
        
        progressViewVisibility = .visible
        
        selectedCategories.forEach{cat in
            
            if let expiredDate = Calendar.current.date(byAdding: .day, value: cat.durationInDays, to: currentTimeStamp.dateValue())  {
                
                let expiredDateTSP = Timestamp(date: expiredDate)
                let catRef = db.collection(REF_FAMILIES).document(familyId).collection(REF_DISTRIBUTED).document()
                
                batch.setData([
                    CATEGORY_NAME: cat.name,
                    DISTRIBUTION_DATE: currentTimeStamp,
                    EXPIRED_DATE: expiredDateTSP,
                    CURR_POINT: distPlace
                ], forDocument: catRef, merge: true)
            }
            
            
        }
        
        batch.commit { err in
            if err == nil {
                
                self.progressViewVisibility = .invisible
                completionHandler(true)
            }
        }
        

        
    }
    
}
