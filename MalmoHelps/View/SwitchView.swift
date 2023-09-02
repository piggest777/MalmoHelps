//
//  TabView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-19.
//

import SwiftUI

struct SwitchView: View {
    
    
    @State private var selectedTabIndex = 0
    var viewModel: SwitchViewModel
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("LightShadow"))
        viewModel = SwitchViewModel()
    }
    var body: some View {
        Group {
            switch viewModel.userStatus {
            case ADMIN, TEACHER:
                tabView(selectedIndex: $selectedTabIndex)
            case VOLUNTEER:
                HomeView()
            case UNDEFINED:
                UnauthPage()
            case LOADING:
                LoadingView()
            default:
               UnauthPage()
            }
        }
        .onAppear{
            viewModel.updateUserStatus()
        }
//        HomeView()
    }
}

@ViewBuilder func tabView(selectedIndex: Binding<Int>) -> some View {
    TabView(selection: selectedIndex) {
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

struct SwitchView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchView()
    }
}
