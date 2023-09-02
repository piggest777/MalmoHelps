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
        Group {
            switch viewModel.authState {
            case .signedIn: SwitchView()
            case .signedOut: AuthView()
                }
            }.alert(viewModel.alertText, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
