//
//  AdminDashboardView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-22.
//

import SwiftUI

struct AdminDashboardView: View {
    @State var showAddActivity = false
    
    var body: some View {
            VStack {
                Text("Hello, Admin!")
                Spacer()
                NavigationLink(destination: ReportView()) {
                    Text("Monthly report".uppercased())
                        .font(Font.headline.weight(.bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("ButtonColor"))
                        .cornerRadius(12)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                StandardButton(text: "Add activity") {
                    showAddActivity.toggle()
                }
                Spacer()
            }.sheet(isPresented: $showAddActivity) {
                AddActivityView(isPresented: $showAddActivity)
            }
    }
}


#Preview {
    AdminDashboardView()
}
