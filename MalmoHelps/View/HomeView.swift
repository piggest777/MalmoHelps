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
    @ObservedObject var familiesLookUp = FamiliesLookupViewModel()
    @State var keyword = ""
    @State var keywordCalled = false
    @State var currFamily: Family? = nil
    @State var navLinkActive = false
    @State var searching = false
    @StateObject var cat  = Categories()
    
    @State var isPresented: Bool = false
    @State var isDeleted = false
    
    var body: some View {
        
        let keywordBinding = Binding<String>(
            get: {
                keyword
            },
            set: {
                if keywordCalled == false {
                    keyword = $0
                    familiesLookUp.queryResultFamilies.removeAll()
                    if keyword.count > 2 {
                        familiesLookUp.keywordSubject.send((keyword, .family))
                    }
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
                            ForEach(familiesLookUp.queryResultFamilies,  id: \.id) { family in
                                FamilyBarView(family: family)
                                    .onTapGesture {
                                        currFamily = family
                                        navLinkActive = true
                                        UIApplication.shared.endEditing()
                                    }
                            }
                        }
                        Spacer()
                        NavigationLink(destination: FamilyDetailsView(family: currFamily ?? Family(place: "", room: "", firstName: "", lastName: "", memberCount: "", notes: "", keywords: [], addingDate: Timestamp(), issueDate: "")), isActive: $navLinkActive) {
                            EmptyView()
                        }.isDetailLink(false)
                    }
                }
            }
            .navigationTitle(Text("Families"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                showAddFamily.toggle()
            }, label: { Image(systemName: "plus") }),
                                trailing:
                                    NavigationLink(destination: ProfileView(), label: {
                Image(systemName: "gear")
            })
            )
        }
        .gesture(DragGesture().onChanged{_ in UIApplication.shared.endEditing()})
        .environment(\.rootPresentationMode, self.$isPresented)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(){
            FsService.shared.getAllCategories{ categories in
                cat.categories = categories
            }
        }
        .sheet(isPresented: $showAddFamily) {
            AddFamilyView(showAddFamily: $showAddFamily, isDeleted: $isDeleted, family: Family(place: "", firstName: "", lastName: "", memberCount: "", keywords: [], addingDate: Timestamp(), issueDate: ""))
        }
        .environmentObject(cat)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(familiesLookUp: FamiliesLookupViewModel())
    }
}



struct FamilyBarView: View {
    var family: Family
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.2))
            VStack {
                Text("\(family.firstName) \(family.lastName)")
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


struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    
    public mutating func dismiss() {
        self.toggle()
    }
}

