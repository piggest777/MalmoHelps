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
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var personalNumber: String = ""
    @State private var abfRegion: String = ""
    @State private var gender: Gender = .undefined
    @State private var city: String = ""
    @State var isValid: Bool = true
    @State private var isKeyboardVisible = false
    @State var isLoading = false
    @State var person: Person?
    
    
    var cities: [City]
    @State var firstNameValidator: Bool = true
    @State var lastNameValidator: Bool = true
    @State var phoneNumberValidator: Bool = true
    @State var personalNumberValidator: Bool = true
    @State var participantCityValidation: Bool = true
    @State var cityValidation: Bool = true
    @State var isPNAbsent: Bool = false
    
    let cityPlaceholder = "Choose city"
    
    var initialFirstName: String = ""
    var initialLastName: String = ""
    var initialPhoneNumber: String = ""
    var initialPersonalNumber: String = ""
    var initialAbfRegion: String = ""
    var initialGender: Gender = .undefined
    var initialCity: String = ""
    
    let genders = Gender.allCases
    let isEditMode: Bool
    var id: String = ""
    
    init(isPresented: Binding<Bool>, person: Person?, isEditMode: Bool = false, cities: [City] = []) {
        self._isPresented = isPresented
        self.isEditMode = isEditMode
        self.cities = cities
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color("DarkShadow"))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .black
        if isEditMode, let person = person {
            self.id = person.id
            self.initialFirstName = person.firstName
            self.initialLastName = person.lastName
            self.initialPhoneNumber = person.phoneNumber
            self.initialPersonalNumber = person.personalNumber
            self.initialAbfRegion = person.abfRegion ?? ""
            self.initialGender = Gender.gender(fromString: person.gender)
            self.initialCity = person.city ?? ""
        }
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                Rectangle()
                    .fill(Color("Background"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack {
                        Spacer().frame(minHeight: 15)
                        ForEach(uiElements, id: \.self) { view in
                            view
                        }
                        
                        WideTextField(title: "Personal Number", placeholder: .required, validatorType: .number, input: $personalNumber, fieldValidation: $personalNumberValidator, isToggleEnabled: true, isAbsent: $isPNAbsent)
                        Menu {
                            ForEach(cities, id: \.id) { cityValue in
                                let city = cityValue.city
                                let region = cityValue.region
                                Button(city) {
                                    self.city = city
                                    abfRegion = region
                                }
                            }
                        } label: {
                            VStack(spacing: 5){
                                Divider()
                                    .overlay(.black)
                                HStack{
                                    Text("City")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.black)
                                    Text(city.isEmpty ? cityPlaceholder : city)
                                        .foregroundColor(city.isEmpty ? .gray : .black)
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.accentColor)
                                        .font(Font.system(size: 20, weight: .bold))
                                        .padding(.trailing, 5)
                                }
                                
                                .frame(height: 50)
                                Divider()
                                    .overlay(.black)
                            }
                            .background(.white)
                        }
                        Menu {
                            ForEach(genders, id: \.self){ type in
                                if type != .undefined {
                                    Button("\(type.rawValue)") {
                                        gender = type
                                    }
                                }
                            }
                            
                        } label: {
                            DropdownMenu<Gender>(menuName: "Gender", value: $gender, placeholder: "Choose gender")
                        }

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
                                    viewModel.alertText = "Please fill all required fields"
                                    return
                                }
                                
                                if !isPNAbsent && (personalNumber.isEmpty || !personalNumberValidator) {
                                    viewModel.showAlert = true
                                    viewModel.alertText = "Please fill personal number"
                                    return
                                }
                                
                                if gender.undefined || city.isEmpty {
                                    viewModel.showAlert = true
                                    viewModel.alertText = "gender or city is undefined"
                                    return
                                }
                                
                                let firstName = firstName.trimSpaces()
                                let lastName = lastName.trimSpaces()
                                
                                let keywords = viewModel.createKeywordsArray(firstName: firstName, lastName: lastName)
                                
                                var startDate: Timestamp {
                                    if let startDate = person?.startDate {
                                        return startDate
                                    }
                                    return Timestamp()
                                }
                                
                                var pn: String {
                                    if isPNAbsent {
                                        return "000000-0000"
                                    }
                                    return personalNumber
                                }

                                person = Person(id: id,firstName: firstName, lastName: lastName, startDate: startDate, finishDate: nil, personalNumber: pn, phoneNumber: phoneNumber, customQrCode: nil, keywords: keywords, abfRegion: abfRegion, city: city, gender: gender.rawValue)
                                
                                if let person {
                                    if person.id.isEmpty, !isPNAbsent {
                                        viewModel.checkPNBeforeAdding(person: person)
                                        return
                                    }
                                    viewModel.addPerson(person)
                                }
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
                                    Text(isEditMode ? "Save".uppercased() : "Add".uppercased())
                                        .font(Font.headline.weight(.bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color("ButtonColor"))
                                        .cornerRadius(12)
                                        .padding()
                                }
                            }.disabled(viewModel.isLoading)
                            .alert(viewModel.alertText, isPresented: $viewModel.showPNAlert, actions: {
                                    Button("Cancel", role: .cancel) {}
                                    Button("Add") {
                                        if let person {
                                            viewModel.addPerson(person)
                                        }
                                    }
                                })
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
                }
            }.navigationTitle(Text(isEditMode ? "Edit person" : "Create person"))
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
                WideTextField(title: "Phone", placeholder: .required, validatorType: .mobilePhone, input: $phoneNumber, fieldValidation: $phoneNumberValidator),
            ])
        }
        .onAppear {
            if isEditMode {
                firstName = initialFirstName
                lastName = initialLastName
                phoneNumber = initialPhoneNumber
                personalNumber = initialPersonalNumber
                abfRegion = initialAbfRegion
                gender = initialGender
                city = initialCity
            }
        }
        
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static let activitiesVM = ActivitiesViewModel()
    static var previews: some View {
        AddPersonView(isPresented: .constant(true), person: nil)
            .environmentObject(activitiesVM)
    }
}

