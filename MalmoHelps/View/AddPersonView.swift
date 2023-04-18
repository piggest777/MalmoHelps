//
//  AddPersonView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-20.
//

import SwiftUI
import Combine
import FirebaseFirestore

enum FieldSRequest: String {
    case required = "Required"
    case optional = "Optional"
}

struct AddPersonView: View {
    @StateObject var viewModel = AddPersonViewModel()
    @Binding var isPresented: Bool
    @State var uiElements: [WideTextField] = []
    var cancellables = Set<AnyCancellable>()
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var phoneNumber: String = ""
    @State var personalNumber: String = ""
    @State var isValid: Bool = true
    @State private var isKeyboardVisible = false
    @State var isLoading = false
    
    
    @State var firstNameValidator: Bool = true
    @State var lastNameValidator: Bool = true
    @State var phoneNumberValidator: Bool = true
    @State var personalNumberValidator: Bool = true
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color("DarkShadow"))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .black
        
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Basic information")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.leading, 20)
                        .font(.title)
                    ForEach(uiElements, id: \.self) { view in
                        view
                    }
                    .gesture(DragGesture().onChanged{_ in UIApplication.shared.endEditing()})
                    Spacer()
                    if !isKeyboardVisible  {
                        Button {
                            if uiElements.contains(where: {$0.fieldValidation == false}) {
                                viewModel.showAlert = true
                                viewModel.alertText = "Format don't satisfy requirements"
                                return
                            }
                            
                            if uiElements.contains(where: { $0.placeholder == .required && $0.input.isEmpty }){
                                viewModel.showAlert = true
                                viewModel.alertText = "Please fill all requirement fields"
                                return
                            }
                            let keywords = viewModel.createKeywordsArray(firstName: firstName, lastName: lastName)
                            
                            let person = Person(firstName: firstName, lastName: lastName, startDate: Timestamp(), finishDate: nil, personalNumber: personalNumber, phoneNumber: phoneNumber, customQrCode: nil, keywords: keywords)
                            viewModel.addPerson(person)
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(12)
                                    .padding()
                            } else {
                                Text("Add".uppercased())
                                    .font(Font.headline.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(12)
                                    .padding()
                            }
                        }.disabled(viewModel.isLoading)
                    }
                }
                .alert(viewModel.alertText, isPresented: $viewModel.showAlert) {
                    Button("OK", role: .cancel) {}
                }
                .onChange(of: viewModel.isPresented) { newValue in
                    isPresented = newValue
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    isKeyboardVisible = true
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    isKeyboardVisible = false
                }
            }.navigationTitle(Text("Create person"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .padding()
                        }
                    }
                }
        }
        .onAppear {
            uiElements.append(contentsOf: [
                WideTextField(title: "First Name", placeholder: .required, validatorType: .required, input: $firstName, fieldValidation: $firstNameValidator),
                WideTextField(title: "Last Name", placeholder: .required, validatorType: .required, input: $lastName, fieldValidation: $lastNameValidator),
                WideTextField(title: "Personal Number", placeholder: .required, validatorType: .number, input: $personalNumber, fieldValidation: $personalNumberValidator),
                WideTextField(title: "Phone", placeholder: .required, validatorType: .mobilePhone, input: $phoneNumber, fieldValidation: $phoneNumberValidator)
            ])
        }
        
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static var previews: some View {
        AddPersonView(isPresented: .constant(true))
    }
}

