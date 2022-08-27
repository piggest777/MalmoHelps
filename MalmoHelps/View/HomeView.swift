//
//  HomeView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State var showAddFamily: Bool = false
    @StateObject var familiesLookUp = FamiliesLookupViewModel()
    @State var keyword = ""
    @State var keywordCalled = false
    
    var body: some View {
        
        let keywordBinding = Binding<String>(
            get: {
                keyword
            },
            set: {
                if keywordCalled == false {
                    keyword = $0
                    familiesLookUp.queryResultUsers.removeAll()
                    familiesLookUp.fetchUsers(with: keyword.lowercased())
                    
                    keywordCalled = true
                } else {
                    keywordCalled = false
                }
            }
        )
        
        NavigationView {
        VStack {
            
        
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                //Add Circle Button
                VStack {
                    
                    SearchBarView(keyword: keywordBinding)
                    ScrollView {
                        ForEach(familiesLookUp.queryResultUsers, id: \.secondName) { family in
                            FamilyBarView(family: family)
                                .onTapGesture {
                                    print("tapped")
                                    NavigationLink(destination: FamilyDetails(family: family)) {
                                        EmptyView()
                                    }
                                    .frame(width: 0)
                                    .opacity(0)
                                    
                                
                                }
                        }
                    }
                    Spacer()
                    circleButton (showAddFamily: $showAddFamily)
                            .frame(alignment: .bottom)
                            .padding(20)
                }
            }

        }
        .navigationTitle(Text("Malmö Helps"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                
        NavigationLink(destination: ProfileView(), label: {
            Image(systemName: "gear")
        })
        )
    }
        .sheet(isPresented: $showAddFamily) {
            AddFamilyView(showAddFamily: $showAddFamily)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView( familiesLookUp: FamiliesLookupViewModel())
    }
}

struct SearchBarView: View {
    @Binding var keyword: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.5))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Searching for...", text: $keyword)
                .autocapitalization(.none)
                Image(systemName: "xmark.circle")
                    .frame(alignment: .trailing)
                    .onTapGesture {
                        keyword = ""
                    }
                    .padding(.trailing, 13)
            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

struct FamilyBarView: View {
    var family: Family
    
    var body: some View {
        ZStack {
            Rectangle()
            .foregroundColor(Color.gray.opacity(0.2))
            VStack {
                Text("\(family.firstName) \(family.secondName)")
                    .padding(.horizontal,10)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(Font.headline.weight(.bold))
                Text("\(family.place) \(family.room ?? "")")
                    .padding(.horizontal,10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .frame(alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 75)
        .cornerRadius(13)
        .padding()
    }
}


