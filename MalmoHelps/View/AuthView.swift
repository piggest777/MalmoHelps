//
//  AuthView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import SwiftUI


struct AuthView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Image("MH_round_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200, alignment: .center)
            Text("MALMÖ HELPS")
                .font(.largeTitle)
            Spacer()
            
            Text("Log in with Google")
            GoogleSignInButton()
                .padding()
                .onTapGesture {
                    viewModel.signIn()
                }
            
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
