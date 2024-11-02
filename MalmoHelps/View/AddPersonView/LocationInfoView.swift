//
//  LocationInfoView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-13.
//

import SwiftUI

struct LocationInfo {
    var city: City
    var countryOfOrigin: String
}

struct LocationInfoView: View {
    @Binding var locationInfo: LocationInfo
    var cities: [City]
    var countries: [String]
    
    
    var body: some View {
        VStack(spacing: 16) {
            Menu {
                ForEach(countries.sorted { $0 < $1 }, id: \.self) { country in
                    Button(country) {
                        locationInfo.countryOfOrigin = country
                    }
                }
            } label: {
                DropdownMenu<String>(menuName: "Country of Origin", value: $locationInfo.countryOfOrigin, placeholder: "Choose country")
            }
            
            Menu {
                Button("Undefined") {
                    locationInfo.city = City(city: "", region: "")
                }
                ForEach(cities, id: \.id) { cityValue in
                    Button(cityValue.city) {
                        let city = City(city: cityValue.city, region: cityValue.region)
                        locationInfo.city = city
                    }
                }
            } label: {
                DropdownMenu<City>(menuName: "City in Sweden", value: $locationInfo.city, placeholder: "Choose city")
            }
        }
        .padding()
    }
}
