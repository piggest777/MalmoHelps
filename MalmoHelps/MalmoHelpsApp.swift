//
//  MalmoHelpsApp.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-20.
//

import SwiftUI
import FirebaseAuth

@main
struct MalmoHelpsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    @StateObject var viewModel = AuthViewModel()
 
    
    var body: some Scene {
        
        
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear(){
                    if Auth.auth().currentUser != nil {
                        viewModel.authState = .signedIn
                    }
                }
        }

    }
}
