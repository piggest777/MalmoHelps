//
//  AuthViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import Firebase
import GoogleSignIn
import SwiftUI

class AuthViewModel: ObservableObject {
    
    @Published var authState: SignInState = .signedOut
    @AppStorage("user_status") var userStatus: String = UNDEFINED
    var alertText = ""
    @Published var showAlert = false
    @Published var reviewMode = false
    
    public enum SignInState {
        case signedIn
        case signedOut
    }
    
    func checkRemoteStatus () {
        RemoteConfigManager.shared.fetchRemoteValues {
            DispatchQueue.main.async {
                self.reviewMode = RemoteConfigManager.shared.getBool(forKey: "reviewMode")
            }
        }
    }
    
    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn() { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {return}
            
            let configuration =  GIDConfiguration (clientID: clientID)
            
            guard let windowScene  = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
            guard let rootViewController = windowScene.windows.first?.rootViewController else {return}
            
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) {[unowned self] user, error in
                authenticateUser(for: user, with: error)
                
            }
            
        }
    }
    
    func signOut() {
      
      GIDSignIn.sharedInstance.signOut()
        userStatus = LOADING
        
      do {
        
        try Auth.auth().signOut()
        
        authState = .signedOut
      } catch {
        print(error.localizedDescription)
      }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      
      if let error = error {
        print(error.localizedDescription)
        self.alertText = "Oops! An error occurred during login. Please try again. \(error.localizedDescription)"
        self.showAlert = true
        return
      }
      
      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      

      Auth.auth().signIn(with: credential) { [unowned self] ( result, error) in
        if let error = error {
          print(error.localizedDescription)
            alertText = "Error while sign in: \(error.localizedDescription)"
            showAlert = true
        } else {
            guard let result else {
                alertText = "No result returned"
                showAlert = true
                return
            }
            FsService.shared.createUser(uid: result.user.uid, name: result.user.displayName ?? String(), email: result.user.email ?? String()) { success, error in
                if success {
                    self.authState = .signedIn
                } else if let error {
                    self.alertText = "Oops! An error occurred during login. Please try again. \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
      }
    }
    
}
