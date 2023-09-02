//
//  ActivitiesViewElement.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-28.
//

import SwiftUI

struct ActivitiesElement: View {
    let activity: ActivityEntry
    
    @Binding var showSearchView: Bool
    @Binding var currActivity: ActivityEntry
    @AppStorage("user_status") var userStatus: String = UNDEFINED
    var action: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Text("\(activity.activityName)")
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(Font.headline.weight(.bold))
                if activity.venue != nil || activity.personInCharge != nil {
                    Text("\(activity.venue ?? "")\((activity.venue != nil && activity.personInCharge != nil) ? ", " : "")\(activity.personInCharge ?? "")")
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if userStatus == ADMIN {
                Button {
                    action()
                } label: {
                    Circle()
                        .fill(Color("DarkShadow"))
                         .frame(width: 40, height: 40)
                         .overlay(
                             Image(systemName: "doc.text")
                                 .foregroundColor(.white)
                                 .font(.system(size: 25, weight: .bold))
                         )
                }
            }

            Button {
                currActivity = activity
                showSearchView.toggle()
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

struct ActivitiesViewElement_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesElement(activity: ActivityEntry(id: "", activityName: "Dancing", venue: nil, personInCharge: "Victoria"), showSearchView: .constant(true), currActivity: .constant(ActivityEntry(id: "", activityName: "Dancing", venue: nil, personInCharge: nil)), action: {})
    }
}
