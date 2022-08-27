//
//  FamiliyDetails.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import SwiftUI

struct FamilyDetails: View {
    
    var family: Family
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FamilyDetails_Previews: PreviewProvider {
    static var previews: some View {
        FamilyDetails(family: Family(place: "Jägersro", firstName: "Denis", secondName: "Rakitin", memberCount: "1", keywords: []))
    }
}

