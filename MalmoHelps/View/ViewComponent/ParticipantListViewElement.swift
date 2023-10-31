//
//  ParticipantListViewElement.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-10.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ParticipantListViewElement: View {
    let person: Person
    var action: ()->Void
    @ObservedObject var viewModel = PersonElementViewModel()
    
    var body: some View {
        HStack {
            VStack {
                Text("\(person.firstName) \(person.lastName)")
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(Font.headline.weight(.bold))
                Text(person.personalNumber)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                action()
            } label: {
                Circle()
                    .fill(Color("DarkShadow"))
                     .frame(width: 40, height: 40)
                     .overlay(
                         Image(systemName: "chevron.right")
                             .foregroundColor(.white)
                             .font(.system(size: 30, weight: .bold))
                     )
            }.padding(.trailing, 20)

        }
        .frame(height: 75)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 3)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
            .stroke(Color.gray, lineWidth: 1)
        }
    }
}

struct ParticipantListViewElement_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantListViewElement(person: Person(firstName: "Denis", lastName: "Rakitin", startDate: Timestamp(), finishDate: Timestamp(), personalNumber: "8909085832", phoneNumber: "", customQrCode: nil, keywords: ["Denis"], abfRegion: nil, city: nil), action: { print("") })
    }
}
