//
//  AuthView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import SwiftUI


struct AuthView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State var login: String = .init()
    @State var password: String = .init()
    @State var loginEditing = false
    @State var passwordEditing = false
    @State var showAlert = false
    @State var alertText = ""
    @State var visibilityProgressView: ViewVisibility = .invisible
    @State var buttonDisabled = false
    
    
    var body: some View {
        ScrollView {
            VStack {
                    Image("MH_round_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200, alignment: .center)
                    .onAppear {
                        viewModel.checkRemoteStatus()
                    }
                Text("MALMÖ HELPS")
                    .font(.largeTitle)
                Spacer().frame(height: 15)
                Text("Log in with Google")
                GoogleSignInButton()
                    .padding(.horizontal, 50)
                    .onTapGesture {
                        viewModel.signIn()
                    }
                    .frame(height: 100)
                if viewModel.reviewMode {
                    Group {
                        Text("Log in with e-mail")
                        VStack {
                            TextWithTextfield(textString: "Login", textBinding: $login, editing: $loginEditing)
                            TextWithTextfield(textString: "Password", textBinding: $password, editing: $passwordEditing)
                            ZStack {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .visibility(visibilityProgressView)
                                
                                Button {
                                    if !login.isEmpty && !password.isEmpty {
                                        
                                        visibilityProgressView = .visible
                                        buttonDisabled = true
                                        
                                        FsService.shared.authUserWithLoginAndPass(login: login, password: password) { success in
                                            if success {
                                                viewModel.authState = .signedIn
                                            }
                                        }
                                        
                                    } else {
                                        alertText = "Please fill login and password"
                                        showAlert = true
                                    }
                                    
                                } label: {
                                    Text("Log In")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color("Background"))
                                        .cornerRadius(12)
                                        .padding()
                                }
                                .disabled(buttonDisabled)
                                .alert(alertText, isPresented: $showAlert) {
                                    Button("OK", role: .cancel) {}
                                }
                            }
                        }.padding(.horizontal, 50)
                            .padding(.vertical, 2)
                            .frame(height: 250)
                    }
                    .padding(.vertical, 5)
                }
                Spacer()
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
