//
//  ParticipantDetatilsElement.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-20.
//

import SwiftUI

struct ParticipantDetailsElement: View {
    let title: String
    let subtitle: String?
    let date: Date
    let duration: Float
    var action: ()->Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }
    
    private var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(title)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(Font.headline.weight(.bold))
                
                if let subtitle {
                    Text(subtitle)
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            
            Text(date, formatter: dateFormatter)
            
            Text((NSNumber(value: duration)), formatter: doubleFormatter)
                .font(Font.headline)
                .foregroundColor(Color.white)
                .padding()
                .background(Color("ButtonColor"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 10)
                .frame(width: 80, height: 60)
                .onTapGesture {
                    action()
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

struct ParticipantDetailsElement_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantDetailsElement(title: "Dancing", subtitle: "Victoria", date: Date(), duration: 1.0, action: {print("Action")})
    }
}


