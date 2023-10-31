//
//  MonthlyReportElement.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-22.
//

import SwiftUI

//TODO: Make element as standard
struct MonthlyReportElement: View {
    let title: String
    let subtitle: String
    let totalHours: Double
//    var action: ()->Void
    @ObservedObject var viewModel = PersonElementViewModel()
    
    var body: some View {
        HStack {
            VStack {
                Text(title)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(Font.headline.weight(.bold))
                Text(subtitle)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(String(format: "%.1f", totalHours))
                .padding(.horizontal, 10)
                .frame(alignment: .trailing)
                .font(Font.title.bold())
            Button {
//                action()
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
        .padding(.horizontal, 10)
    }
}


#Preview {
    MonthlyReportElement(title: "Denis Rakitin", subtitle: "19890908-5832", totalHours: 8.54214)
}
