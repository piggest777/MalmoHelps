//
//  AddCatetegory.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-28.
//

import SwiftUI
import Combine

struct AddCategoryView: View {
    
    @ObservedObject var vm = AddCategoryViewModel()
    @EnvironmentObject var  cat: Categories
    @Binding var showAddCategoryView: Bool
    @State var catName = ""
    @State var catNameEditing = false
    @State var catDuration = ""
    @State var durationEditing = false
    
    
    var body: some View {
        
        NavigationView {
        VStack {
        TextWithTextfield(textString: "Category", textBinding: $catName, editing: $catNameEditing)
        
        Text("Category time period")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 16, weight: .bold, design: .default))
            TextField("Category time period", text: $catDuration, onEditingChanged: { edit in
                self.durationEditing = edit
            })
            .onReceive(Just(catDuration)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    self.catDuration = filtered
                }
            }
            .textFieldStyle(MyTextFieldStyle(focused: $durationEditing))
            .keyboardType(.numberPad)
            .padding(.bottom)
            
            Spacer()
            
            ZStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .visibility(vm.progressViewVisibility)
                
                StandardtButton(color: Color(.systemMint), text: "Add category") {
                    
                    if !catName.isEmpty && !catDuration.isEmpty, let numericDuration = Int(catDuration) {
                        let newCategory = Category(name: catName, durationInDays: numericDuration)
                        vm.addCategory(category: newCategory)
                        
                        FsService.shared.getAllCategories { cat in
                            self.cat.categories = cat
                            showAddCategoryView = false
                        }
                        
                    } else {
                        vm.alertText = "Please fill all fields correctly"
                        vm.errorWhileAdding = true
                    }
                    print("added")
                }
                .alert(vm.alertText, isPresented: $vm.errorWhileAdding) {
                    Button("OK", role: .cancel) {}
            }
            }
            
        }.padding()
            .environmentObject(cat)
            .navigationTitle("Add new item")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddCategoryView = false
                    } label: {
                        Image(systemName: "xmark.circle")
                    }

                }
            }
        }
    }
}

struct AddCatetegory_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView(showAddCategoryView: .constant(true))
    }
}
