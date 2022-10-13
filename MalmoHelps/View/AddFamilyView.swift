//
//  AddFamilyView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-23.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct AddFamilyView: View {
    
    @Binding var showAddFamily: Bool
    @State var liveInMGS: Bool = true
    @State var placeDefinition = "Room #"
    @State var room = ""
    @State var place = ""
    @State var firstName = ""
    @State var secondName = ""
    @State var familySize = ""
    @State var notes = ""
    @State var placeholder = "Place for short notes"
    @State var editingPlace  = false
    @State var editingFirst = false
    @State var editingSecond = false
    @State var editingNumberOfFamilies = false
    @State var showAlert = false
    @State var alertText = ""
    @State var visibilityProgressView: ViewVisibility = .invisible
    @State var buttonDisabled = false
    
    var family: Family
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 0){
                
                
                Group {
                Toggle(isOn: $liveInMGS) {
                    Text("Does live on Jägersro")
                }
                .onChange(of: liveInMGS, perform: { newValue in
                    if newValue {
                        placeDefinition = "Room #"
                    } else {
                        placeDefinition = "Place"
                    }
                })
                .padding(2)
                
                    
                TextWithTextfield(textString: placeDefinition, textBinding: $place, editing: $editingPlace)
                
                TextWithTextfield(textString: "First name", textBinding: $firstName, editing: $editingFirst)

                TextWithTextfield(textString: "Second name", textBinding: $secondName, editing: $editingSecond)
                    
                }

                    
                
                Text("Family size")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    TextField("Family size", text: $familySize, onEditingChanged: { edit in
                        self.editingNumberOfFamilies = edit
                    })
                    .onReceive(Just(familySize)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.familySize = filtered
                        }
                    }
                    .textFieldStyle(MyTextFieldStyle(focused: $editingNumberOfFamilies))
                    .keyboardType(.numberPad)
                    .padding(.bottom)
                
                Text("Notes")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 14, design: .default))
                
                
                ZStack {
                    if self.notes.isEmpty {
                            TextEditor(text:$placeholder)
                                .font(.body)
                                .foregroundColor(.gray)
                                .disabled(true)
                                .addBorder(Color.red, width: 1, cornerRadius: 10)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 75)
                                .padding(.horizontal, 5)
                    }
                    TextEditor(text: $notes)
                        .font(.body)
                        .opacity(self.notes.isEmpty ? 0.25 : 1)
                        .addBorder(Color.gray, width: 3, cornerRadius: 10)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 75)
                        .padding(.horizontal, 5)
                }

                Spacer(minLength: 20)
                    ZStack {
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                            .visibility(visibilityProgressView)
                            
                        Button {
                        if !place.isEmpty && !secondName.isEmpty {
                            var keywords = [String]()
                            
                            if liveInMGS {
                                room = place
                                place = "Jägersro"
                                keywords.append(contentsOf: room.generateStringSequence())
                                
                            } else {
                                room = ""
                            }
                            keywords.append(contentsOf:  place.generateStringSequence())
                            keywords.append(contentsOf: firstName.generateStringSequence())
                            keywords.append(contentsOf: secondName.generateStringSequence())
                            
                            var room: String?
                            var notes: String?
                            
                            if self.notes != "" {notes = self.notes} else {room = notes}
                            
                            if self.room != "" {room = self.room} else {room = nil}
                            showAlert = false
                            
                            
                            let newFamily = Family(id: family.id, place: place, room: room, firstName: firstName, secondName: secondName, memberCount: familySize, notes: notes, keywords: keywords, addingDate: Timestamp())
                            visibilityProgressView = .visible
                            buttonDisabled = true
                            
                            
                            if family.id.isEmpty {
                                FsService.shared.addFamilyToDB(family: newFamily) { success in
                                    if success {
                                        showAddFamily  = false
                                        visibilityProgressView = .invisible
                                        buttonDisabled = false
                                        print("Added")
                                    } else {
                                        alertText = "Something goes wrong while adding, try one more time"
                                        showAlert = true
                                    }
                                }
                            } else {
                                FsService.shared.updateFamily(family: newFamily) { success in
                                    if success {
                                        showAddFamily  = false
                                        visibilityProgressView = .invisible
                                        buttonDisabled = false
                                        print("Edited")
                                    } else {
                                        alertText = "Something goes wrong while adding, try one more time"
                                        showAlert = true
                                    }
                                }
                            }


                            
                        } else {
                            alertText = "Please fill place, first and second name"
                            showAlert = true
                        }
                        
                    } label: {
                        Text("Add Family")
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

                }
            }.onAppear{
                firstName = family.firstName
                secondName = family.secondName
                familySize = family.memberCount
                place = family.place
                room = family.room ?? ""
                notes = family.notes ?? ""
                if let room = family.room, room.isEmpty {
                    liveInMGS = false
                }
            }
            .padding(.horizontal)
            .navigationTitle("Add new family")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddFamily = false
                    } label: {
                        Image(systemName: "xmark.circle")
                    }

                }
            }
        }
    }
}

struct AddFamilyView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddFamilyView(showAddFamily: .constant(true), family: Family(place: "", firstName: "", secondName: "", memberCount: "", keywords: [], addingDate: Timestamp()))
    }
}


struct MyTextFieldStyle: TextFieldStyle {
    @Binding var focused: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(focused ? Color.red : Color.gray, lineWidth: 3)
        ).padding(.horizontal,5)
    }
}

