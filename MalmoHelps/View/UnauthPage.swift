//
//  UnauthPage.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-08-13.
//

import SwiftUI
import FirebaseAuth

struct UnauthPage: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var userEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                LottieView(name: "noauth")
                    .frame(width: 200,height: 200)
                Text("You account \(userEmail) is not authorised. Please contact with administrator to get access(den.rakitin@icloud.com)")
                    .font(.title3)
                    .foregroundColor(Color(red: 105/255, green: 105/255, blue: 105/255))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                
                Button(action: {
                    viewModel.updateUserStatus()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise") // This is the refresh icon from SF Symbols
                            .font(.headline)
                        Text("Refresh status")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue) // Use your desired color here
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                Button(action: viewModel.signOut ) {
                    Text("Sign out")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemMint))
                        .cornerRadius(12)
                        .padding()
                }
                Spacer()
            }
        }
    }
}

struct UnauthPage_Previews: PreviewProvider {
    static var previews: some View {
        UnauthPage()
            .environmentObject(AuthViewModel())
    }
}
