//
//  AddCategoryViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-28.
//

import Foundation
import FirebaseFirestore

class AddCategoryViewModel: ObservableObject {
    
    @Published var progressViewVisibility: ViewVisibility = .invisible
    @Published var errorWhileAdding = false
    @Published var alertText = ""
    private let db = Firestore.firestore()

    func addCategory(category: Category) {
        progressViewVisibility = .visible
        db.collection(CATEGORIES).document().setData([
            CATEGORY_NAME : category.name,
            DURATION : category.durationInDays], merge: true) { err in
                if err == nil {
                    self.progressViewVisibility = .invisible
                } else {
                    self.progressViewVisibility = .invisible
                    self.errorWhileAdding = true
                    self.alertText = "Error while adding category"
                }
                
            }
        
        
    }
}
