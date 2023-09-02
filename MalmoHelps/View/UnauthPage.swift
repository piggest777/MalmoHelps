//
//  UnauthPage.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-08-13.
//

import SwiftUI

struct UnauthPage: View {
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                LottieView(name: "noauth")
                    .frame(width: 200,height: 200)
                Text("You account is not authorised. Please contact with administrator to get access(den.rakitin@icloud.com)")
                    .font(.title3)
                    .foregroundColor(Color(red: 105/255, green: 105/255, blue: 105/255))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                Spacer()
            }
        }

    }
}

struct UnauthPage_Previews: PreviewProvider {
    static var previews: some View {
        UnauthPage()
    }
}
