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
    @StateObject var viewModel: AddPersonValidatorViewModel
    
    @State private var currentStep = 1
    @State private var personalInfo = PersonalInfo(firstName: "", lastName: "", phoneNumber: "", personalNumber: "", gender: .undefined, documentType: .undefined, ageGroup: .undefined)
    @State private var locationInfo = LocationInfo(city: City(city: "", region: ""), countryOfOrigin: "")
    
    @Binding var isPresented: Bool
    let isEditMode: Bool
    var person: Person?
    var cities: [City]
    var countries: [String]
    
    init(isPresented: Binding<Bool>, person: Person?, isEditMode: Bool = false, cities: [City] = [], countries: [String] = []) {
        self._isPresented = isPresented
        self.isEditMode = isEditMode
        self.person = person
        self.cities = cities
        self.countries = []
        
        _viewModel = StateObject(wrappedValue: AddPersonValidatorViewModel(isPresented: isPresented))
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color("DarkShadow"))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .black
        
        self.countries = getCountryList()
    }
    
    func getCountryList() -> [String] {
        var countryList: [String] = []

        // Iterate over ISO country codes
        for code in NSLocale.isoCountryCodes {
            // Generate the country flag using the emoji flag function
            let flag = countryFlag(from: code)
            
            // Get the localized country name using the code
            let locale = Locale(identifier: "en_UK")
            if let countryName = locale.localizedString(forRegionCode: code) {
                // Append the formatted string with the flag and country name
                countryList.append("\(flag) \(countryName)")
            }
        }
        
        var sortedList = countryList.sorted { $0 < $1 }

        // Move Ukraine to the top of the list
        if let index = sortedList.firstIndex(where: { $0.contains("🇺🇦 Ukraine") }) {
            let ukraine = sortedList.remove(at: index)
            sortedList.insert(ukraine, at: 0)
        }

        // Sort the country list alphabetically
        return sortedList
    }
    
    
    // Helper function to create emoji flag from the country code
    func countryFlag(from countryCode: String) -> String {
        let base: UInt32 = 127397
        var flagString = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flagString.unicodeScalars.append(scalarValue)
            }
        }
        return flagString
    }
    
    
    var body: some View {
           NavigationView {
               ZStack {
                   Background()
                   VStack {
                       VStack {
                           if currentStep == 1 {
                               PersonalInfoView(personalInfo: $personalInfo)
                               Spacer()
                               CustomActionButton(title: "Next", isLoading: $viewModel.isLoading) {
                                   if viewModel.validatePersonalInfo(personalInfo: personalInfo) {
                                       currentStep = 2
                                   }
                               }
                           } else if currentStep == 2 {
                               DocumentInfoView(personalInfo: $personalInfo)
                               Spacer()
                               CustomActionButton(title: "Next", isLoading: $viewModel.isLoading) {
                                   if viewModel.validateDocumentInfo(personalInfo: personalInfo) {
                                       currentStep = 3
                                   }
                               }
                           } else if currentStep == 3 {
                               LocationInfoView(locationInfo: $locationInfo, cities: cities, countries: countries)
                               Spacer()
                               CustomActionButton(title: isEditMode ? "Save" : "Submit", isLoading: $viewModel.isLoading) {
                                   if viewModel.validateLocationInfo(locationInfo: locationInfo) {
                                       viewModel.handlePersonSave(
                                        person: isEditMode ? person : nil,
                                        personalNumber: personalInfo.personalNumber,
                                        isPNAbsent: personalInfo.personalNumber.isEmpty,
                                        id: isEditMode ? person?.id ?? "" : UUID().uuidString,
                                        firstName: personalInfo.firstName,
                                        lastName: personalInfo.lastName,
                                        phoneNumber: personalInfo.phoneNumber,
                                        abfRegion: locationInfo.city.region,
                                        city: locationInfo.city.city,
                                        gender: personalInfo.gender.rawValue,
                                        documentType: personalInfo.documentType.rawValue,
                                        ageGroup: personalInfo.ageGroup.rawValue,
                                        countryOfOrigin: locationInfo.countryOfOrigin
                                       )
                                   }
                               }
                           }
                       }
                   }
               }
               .onAppear {
                   if isEditMode, let person = person {
                       let personalInfo = PersonalInfo(
                           firstName: person.firstName,
                           lastName: person.lastName,
                           phoneNumber: person.phoneNumber,
                           personalNumber: person.personalNumber,
                           gender: Gender.gender(fromString: person.gender),
                           documentType: DocumentType.documentType(from: person.documentType) ,
                           ageGroup: AgeGroup.ageGroup(fromString: person.ageGroup)
                       )
                       let locationInfo = LocationInfo(
                           city: City(city: person.city ?? "", region: person.abfRegion ?? ""),
                           countryOfOrigin: person.countryOfOrigin
                       )
                       self.personalInfo = personalInfo
                       self.locationInfo = locationInfo
                       print(self.personalInfo.firstName)
                       print(self.locationInfo.city.city)
                   }
               }
               .navigationTitle(Text(isEditMode ? "Edit person" : "Create person"))
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
               .alert(viewModel.alertText, isPresented: $viewModel.showAlert) {
                   Button("OK", role: .cancel) {}
               }
           }
       }
}

struct AddPersonView_Previews: PreviewProvider {
    static let activitiesVM = ActivitiesViewModel()
    static var previews: some View {
        AddPersonView(isPresented: .constant(true), person: nil, cities: [City(city: "Lund", region: "South")])
    }
}
