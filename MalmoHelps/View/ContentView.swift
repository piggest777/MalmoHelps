//
//  ContentView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-20.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        switch viewModel.authState {
        case .signedIn: HomeView()
        case .signedOut: AuthView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
