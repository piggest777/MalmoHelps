//
//  PersonElement.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-08.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import Combine

struct PersonElement: View {
    let person: Person
    let date: Date
    let activity: ActivityEntry
//    let activityName: String
//    let defaultDuration: Float?
//    let personInCharge: String?
//    let venue: String?
    var showDuration: Bool
    @State var duration: Float = 1.0
    var action: () -> Void
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
            
            if showDuration {
                FloatingTextField(floatValue: $duration, placeholder: "1.0")
            }
            Button {
                viewModel.addParticipant(for: person, at: date, activity: activity)
                action()
            } label: {
                Circle()
                    .fill(Color("DarkShadow"))
                     .frame(width: 40, height: 40)
                     .overlay(
                         Image(systemName: "plus")
                             .foregroundColor(.white)
                             .font(.system(size: 30, weight: .bold))
                     )
            }.padding(.trailing, 20)

        }
        .onAppear{
            if activity.defaultDuration != nil {
                duration = activity.defaultDuration ?? 1.0
            }
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

struct PersonElement_Previews: PreviewProvider {
    static var previews: some View {
        
        PersonElement(person: Person(firstName: "Denis", lastName: "Rakitin", startDate: Timestamp(), finishDate: Timestamp(), personalNumber: "8909085832", phoneNumber: "", customQrCode: nil, keywords: ["Denis"], abfRegion: nil, city: nil), date: Date(), activity: ActivityEntry(id: "", activityName: "Dance", venue: "Malmo", personInCharge: "Victoria"), showDuration: true, action: {print("")})
    }
}
