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
    
    var body: some View {
        VStack {
            Text("Please choose current distribution point")
                .font(.title3)
                .padding()
            Menu {
                ForEach(DIST_POINTS, id: \.id){ point in
                    Button("\(point.name)") {
                        distPlace = point.name
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
    }
}


