//
//  HomeView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State var showAddFamily: Bool = false
    @StateObject var familiesLookUp = FamiliesLookupViewModel()
    @State var keyword = ""
    @State var keywordCalled = false
    @State var currFamily: Family? = nil
    @State var navLinkActive = false
    @State var searching = false
    @StateObject var cat  = Categories()
    
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
                    
                    SearchBarView(keyword: keywordBinding, searching: $familiesLookUp.searching)
                    ScrollView {
                        ForEach(familiesLookUp.queryResultUsers,  id: \.id) { family in
                           FamilyBarView(family: family)
                                .onTapGesture {
                                    currFamily = family
                                    navLinkActive = true
                                }
                        }
                    }
                    Spacer()
                    circleButton (showAddFamily: $showAddFamily)
                            .frame(alignment: .bottom)
                            .padding(20)
                    
                    NavigationLink(destination: FamilyDetailsView(family: currFamily ?? Family(place: "", room: "", firstName: "", secondName: "", memberCount: "", notes: "", keywords: [], addingDate: Timestamp())), isActive: $navLinkActive) {
                        EmptyView()
                    }
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

        }.onAppear(){
            FsService.shared.getAllCategories{ categories in
                cat.categories = categories
            }
            
        }
        .sheet(isPresented: $showAddFamily) {
            AddFamilyView(showAddFamily: $showAddFamily, family: Family(place: "", firstName: "", secondName: "", memberCount: "", keywords: [], addingDate: Timestamp()))
        }
        .environmentObject(cat)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView( familiesLookUp: FamiliesLookupViewModel())
    }
}

struct SearchBarView: View {
    @Binding var keyword: String
    @Binding var searching: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.5))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Searching for...", text: $keyword)
                .autocapitalization(.none)
                
                if searching {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(alignment: .trailing)
                        .padding(.trailing, 13)
                } else {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30,alignment: .trailing)
                        .onTapGesture {
                            keyword = ""
                        }
                        .padding(.trailing, 13)
                }

            }
            .padding(.leading, 13)
        }
        .frame(height: 50)
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
        .padding(.horizontal, 10)
    }
}


