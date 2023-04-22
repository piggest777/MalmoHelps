//
//  TabView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-19.
//

import SwiftUI

struct SwitchView: View {
    @State private var selectedTabIndex = 0
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("LightShadow"))
    }
    var body: some View {
//        HomeView()
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tabItem {
                    Image(systemName: "person.3.sequence.fill")
                    Text("Queue")
                }
                .tag(0)

            ActivitiesView()
                .tabItem {
                    Image(systemName: "rectangle.stack.badge.person.crop.fill")
                    Text("Activities")
                }
                .tag(1)
        }
    }
}

struct SwitchView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchView()
    }
}
