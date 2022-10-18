//
//  FamiliyDetails.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import SwiftUI
import FirebaseFirestore

struct FamilyDetailsView: View {
    
    var family: Family
    @State var navLinkActive: Bool = false
    @StateObject var vm = SharedItemsViewModel()
    @State var showSheet = false
    @State private var isExpanded: Bool = false
    
    
    var body: some View {
        VStack{
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.white)
                    .shadow(radius: 10)
                
                    HStack {
                        VStack {
                            Text("\(family.firstName) \(family.secondName)")
                                .font(Font.headline.weight(.bold))
                                .frame( maxWidth: .infinity, alignment: .leading)
                            Text("Place: \(family.place) \(family.room ?? "")")
                                .font(Font.system(size: 15, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame( maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            Text("Family size: \(family.memberCount)")
                                .font(Font.system(size: 15, weight: .thin))
                            
                            Text("Adding date: \(family.addingDate.dateValue().toString())")
                                .font(Font.system(size: 15, weight: .thin))
                            
                        }.frame( maxWidth: .infinity,alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding()
            }
            .frame( height: 100)
                .padding(.horizontal, 10)
            if let notes = family.notes, !notes.isEmpty {
                Text(notes)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 15)
                    .font(Font.system(size: 15, weight: .thin))
                    .lineLimit(isExpanded ? nil : 2)
                    .overlay(
                        GeometryReader { proxy in
                            Button(action: {
                                isExpanded.toggle()
                            }) {
                                Text(isExpanded ? "Less" : "More")
                                    .font(.caption).bold()
                                    .padding(.leading, 8.0)
                                    .padding(.top, 4.0)
                                    .background(Color.white)
                            }
                            
                            .frame(width: proxy.size.width-15, height: proxy.size.height, alignment: .bottomTrailing)
                        }
                    )
                
            }


            List(vm.itemList, id: \.id ) { item in
                HStack{
                VStack{
                    Text(item.category)
                        .font(Font.system(size: 16, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity,  alignment: .leading)
                    Text(item.distributionDate.toMonthDayString())
                        .font(Font.system(size: 12, weight: .thin, design: .rounded))
                        .foregroundColor(Color.gray)
                        .padding(.leading, 5)
                        .frame(maxWidth: .infinity,  alignment: .leading)
                }
                .frame(maxWidth: .infinity,  alignment: .leading)
                    
                    
                    Text( item.expiredDate.toMonthDayString())
                        .font(Font.system(size: 16, weight: .semibold, design: .rounded))
                        .frame( alignment: .trailing)
                    
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
            }
        
        
        Button {
            navLinkActive = true
        } label: {
        Text("Distribute")
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemMint))
        .cornerRadius(12)
        .padding()
        }
        
            NavigationLink(destination: DistributeView(family: family), isActive: $navLinkActive) {
            EmptyView()
        }
        }.onAppear() {
            vm.itemList.removeAll()
            vm.familyId = family.id
            vm.downloadSharedItems(listSize: .short)
        }
        .sheet(isPresented: $showSheet) {
            AddFamilyView(showAddFamily: $showSheet, family: family)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSheet = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.circle")
                        Text("Edit")
                            .font(.callout)
                    }
                }

            }
        }


    }
    
    
}

struct FamilyDetails_Previews: PreviewProvider {
    static var previews: some View {
        FamilyDetailsView(family: Family(place: "Jägersro", firstName: "Denis", secondName: "Rakitin", memberCount: "1", notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Senectus et netus et malesuada fames ac turpis egestas sed. A iaculis at erat pellentesque adipiscing commodo elit at. Et ligula ullamcorper malesuada proin libero. In arcu cursus euismod quis. Vitae auctor eu augue ut lectus arcu. Nam at lectus urna duis convallis convallis tellus id interdum. Tellus in metus vulputate eu scelerisque felis. In ante metus dictum at tempor commodo ullamcorper a lacus. Cursus eget nunc scelerisque viverra mauris in. Ac felis donec et odio pellentesque diam volutpat commodo sed.", keywords: [], addingDate: Timestamp()))
    }
}



