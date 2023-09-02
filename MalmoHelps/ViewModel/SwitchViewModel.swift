//
//  SwitchViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-08-13.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseAuth

class SwitchViewModel: ObservableObject {
    @AppStorage("user_status") var userStatus: String = LOADING
    var cancellables = Set<AnyCancellable>()
        
    func updateUserStatus() {
        guard let userUid = Auth.auth().currentUser?.uid else {
            userStatus = UNDEFINED
            return
        }
        FsService.shared.getUser(uid: userUid)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error while fetching user: \(error.localizedDescription)")
                    self.userStatus = UNDEFINED
                case .finished:
                    print("User fetched successfully")
                }
            } receiveValue: { user in
                switch user.role {
                case ADMIN:
                    self.userStatus = ADMIN
                case TEACHER:
                    self.userStatus = TEACHER
                case VOLUNTEER:
                    self.userStatus = VOLUNTEER
                default:
                    self.userStatus = UNDEFINED
                }
            }.store(in: &cancellables)
    }    
}






