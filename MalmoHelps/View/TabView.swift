//
//  TabView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-19.
//

import SwiftUI

struct SwitchView: View {
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("First")
                }
                .tag(0)
            
            ActivitiesView()
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("Second")
                }
                .tag(1)
        }
        .background(Color.white)
    }
}

struct SwitchView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchView()
    }
}
