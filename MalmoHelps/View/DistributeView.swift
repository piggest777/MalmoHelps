//
//  DistributeView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import SwiftUI
import FirebaseFirestore

struct DistributeView: View {
    
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("distribution_place") var distPlace: String = ""
    
    var family: Family
    @EnvironmentObject var cat: Categories
    @State var showAddCategoryView: Bool = false
    @State var selectedCategory = [Category]()
    @ObservedObject var vm = DistributeViewModel()
    @State var buttonDisabled = false
    
    
    var body: some View {
        VStack {
            Text("Distribution point: \(distPlace)")
                .font(.title3)
                .padding(.bottom, 10)
            ScrollView{
                ForEach(cat.categories, id: \.id) { cat in
                    CategoryItemWithCheckBoxView (category: cat, checkedCategory: $selectedCategory)
                }
            }
            .onChange(of: selectedCategory, perform: { newValue in
                print(selectedCategory)
            })
            .sheet(isPresented: $showAddCategoryView){ AddCategoryView(showAddCategoryView: $showAddCategoryView)}
            
            ZStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .visibility(vm.progressViewVisibility)
            
            StandardtButton(color: Color(.systemMint), text: "Finish") {
                buttonDisabled = true
                vm.addCategoriesToFamily(familyId: family.id, selectedCategories: selectedCategory){ success in
                    if success {
                        buttonDisabled = false
                        dismiss()
                    }
                    
                }
            }.disabled(buttonDisabled)
                
            }
            
            
        }.environmentObject(cat)
            .navigationTitle("Distribute")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                showAddCategoryView = true
            }, label: {
                Image(systemName: "note.text.badge.plus")
            })
            )

            
    }
}

struct DistributeView_Previews: PreviewProvider {
    static var previews: some View {
        DistributeView(family: Family(id: "", place: "", room: "", firstName: "", secondName: "", memberCount: "", notes: "", keywords: [], addingDate: Timestamp()))
    }
}

struct CategoryItemWithCheckBoxView: View {
    @State var checked: Bool = false
    var category: Category
    @Binding var checkedCategory: [Category]

    var body: some View {
            ZStack {
                Rectangle()
                .foregroundColor(Color.gray.opacity(0.1))
                HStack {
                    Image(systemName: checked ? "checkmark.square.fill" : "square")
                        .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
                        .onTapGesture {
                            self.checked.toggle()
                            if self.checked {
                                checkedCategory.append(category)
                            } else {
                               if let index = checkedCategory.firstIndex(of: category) {
                                   checkedCategory.remove(at: index)
                               }
                            }
                        }
                    
                    HStack {
                        Text("\(category.name)")
                            .padding(.horizontal,5)
                            .frame(alignment: .leading)
                        .font(Font.headline.weight(.semibold))
                        
                        Text("(\(category.durationInDays) days)")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .font(Font.headline.weight(.thin))
                    }
                }
                .padding(.horizontal, 10)
                .frame(alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .cornerRadius(13)
            .padding(.horizontal, 10)
            .shadow(radius: 10)
    }
}
