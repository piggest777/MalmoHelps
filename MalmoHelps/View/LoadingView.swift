//
//  LoadingView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-08-20.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                LottieView(name: "loading")
                    .frame(width: 200,height: 200)
                Spacer()
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
