//
//  ProfileViewModel.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-09-24.
//

import Foundation
import CryptoKit
import FirebaseFirestoreSwift
import FirebaseAuth
import AuthenticationServices
import SwiftUI

class ProfileViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @Published var isSignedOut = false
    @Published var isLoading = false
    fileprivate var currentNonce: String?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
    
    func deleteCurrentUser() {
        
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
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
      guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
      else {
        print("Unable to retrieve AppleIDCredential")
        return
      }

      guard let _ = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }

      guard let appleAuthCode = appleIDCredential.authorizationCode else {
        print("Unable to fetch authorization code")
        return
      }

      guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
        print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
        return
      }
        
        print(authCodeString)
        
    
      Task {
        do {
            let user = Auth.auth().currentUser
            isLoading = true
            if let token = try await getToken(authCode: authCodeString) {
                print("Received token:", token)
                try await removeAccount(token: token)
                FsService.shared.deleteUserFromFirestore(uid: user?.uid) { success in
                    if success {
                        self.isLoading = false
                        self.isSignedOut.toggle()
                    }
                }
            } else {
                print("Failed to get token or token is empty.")
            }

        } catch {
          print("Error while delete user: \(error)")
        }
      }
    }
    
    func removeAccount(token: String) async throws {
        // Ensure URL encoding and creation is successful.
        guard let encodedURL = "https://us-central1-malmohelps.cloudfunctions.net/revokeToken?refresh_token=\(token)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

    }

    
    func getToken(authCode: String) async throws -> String? {
        guard let encodedURL = "https://us-central1-malmohelps.cloudfunctions.net/getRefreshToken?code=\(authCode)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            // If unable to create the URL, throw an error
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        // Optional: Check if the response has a status code in the range 200-299 (success)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        // Convert data to string and return
        return String(data: data, encoding: .utf8)
    }

    
}
