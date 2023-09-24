//
//  ProfileView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import SwiftUI



struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("distribution_place") var distPlace: String = ""
     var placeHolder = "Please choose"
    @StateObject var profileVM = ProfileViewModel()

    var body: some View {
        VStack {
            Text("Please choose current distribution point")
                .font(.title3)
                .padding()
            Menu {
                ForEach(DIST_POINTS, id: \.self){ point in
                    Button("\(point.venue)") {
                        distPlace = point.venue
                    }
                }
                
            } label: {
                VStack(spacing: 5){
                    HStack{
                        Text(distPlace.isEmpty ? placeHolder : distPlace)
                            .foregroundColor(distPlace.isEmpty ? .gray : .black)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.accentColor)
                            .font(Font.system(size: 20, weight: .bold))
                    }
                    //                                    .padding(.horizontal)
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(maxWidth: 100, maxHeight: 2)
                }
                
            }
            Spacer()
            Button(action: profileVM.deleteCurrentUser) {
                if profileVM.isLoading {
                    ZStack {
                        Rectangle()
                            .background(Color(.black))
                            .cornerRadius(12)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                        ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    Text("Delete Apple Account")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.black))
                        .cornerRadius(12)
                        .padding(.horizontal, 15)

                }
            }.onChange(of: profileVM.isSignedOut) { value in
                if value == true {
                    viewModel.authState = .signedOut
                }
            }
            
            Button(action: viewModel.signOut) {
                Text("Sign out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemMint))
                    .cornerRadius(12)
                    .padding()
            }
        }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}


