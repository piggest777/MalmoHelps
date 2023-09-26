//
//  AuthViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import Firebase
import GoogleSignIn
import SwiftUI
import CryptoKit
import AuthenticationServices
import Combine

class AuthViewModel: NSObject, ObservableObject  {
    
    @Published var authState: SignInState = .signedOut
    @AppStorage("user_status") var userStatus: String = UNDEFINED
    var alertText = ""
    @Published var showAlert = false
    @Published var reviewMode = false
    var cancellables = Set<AnyCancellable>()
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
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

        signInWithFirebase(credential: credential)
    }
    
    func signInWithFirebase(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [unowned self] ( result, error) in
          if let error = error {
            print(error.localizedDescription)
              alertText = "Error while sign in: \(error.localizedDescription)"
              showAlert = true
          } else {
              handleAuthResult(result: result)
          }
        }
      }
    
    func handleAuthResult(result: AuthDataResult?) {
        guard let result else {
            alertText = "No result returned"
            showAlert = true
            return
        }
        FsService.shared.createUser(uid: result.user.uid, name: result.user.displayName ?? String(), email: result.user.email ?? String()) { success, error in
            if success {
                print("Successfully signed in")
                self.authState = .signedIn
            } else if let error {
                self.alertText = "Oops! An error occurred during login. Please try again. \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
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



//Apple sign-id
extension AuthViewModel {
    func startSignInWithAppleFlow() {
        let cryptoUtils = CryptoUtils()
        let nonce = cryptoUtils.randomNonceString()
      currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = cryptoUtils.sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    
}

extension AuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completeAppleAuth(authorization: authorization)
      }
    
    func authWithoutController(didCompleteWithAuthorization authorization: ASAuthorization) {
        completeAppleAuth(authorization: authorization)
      }
    
    private func completeAppleAuth(authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential, including the user's full name.
          let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                            rawNonce: nonce,
                                                         fullName: appleIDCredential.fullName)
          // Sign in with Firebase.
            signInWithFirebase(credential: credential)
        }
    }
    
    
    func authorizationController(didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential, including the user's full name.
          let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                            rawNonce: nonce,
                                                         fullName: appleIDCredential.fullName)
            
            
          // Sign in with Firebase.
            signInWithFirebase(credential: credential)
        }
      }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
      }

}

extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}


