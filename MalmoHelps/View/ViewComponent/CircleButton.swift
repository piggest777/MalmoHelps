//
//  circleButton.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-22.
//

import SwiftUI

struct circleButton: View {
    
    @State var circleTapped = false
    @State var circlePressed = false
    
    @Binding var showAddFamily: Bool
    
    var body: some View {
        ZStack {
            Image(systemName: "plus")
                .font(.system(size: 40, weight: .light))
                .offset(x: circlePressed ? -90 : 0, y: circlePressed ? -90 : 0)
                .rotation3DEffect(Angle(degrees: circlePressed ? 20 : 0),
                                        axis: (x: 10, y: -10, z: 0))
        }
        .frame(width: 60, height: 60)
        .background(
            ZStack {
                Circle()
                    .fill(Color("Background"))
                    .frame(width: 75, height: 75)//Button Size.
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            }
        )
        .scaleEffect(circleTapped ? 1.2 : 1)
        .onTapGesture(count: 1) {
            self.circleTapped.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.circleTapped = false
                showAddFamily = true
            }
        }
    }
}
