//
//  DropdownMenu.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-15.
//

import SwiftUI

struct DropdownMenu<EnumType: DropdownEnum>: View {
    
    let menuName: String
    @Binding var value: EnumType
    var placeholder: String = "undefined"
    
    var body: some View {
            VStack(spacing: 5){
                Divider()
                    .overlay(.black)
                HStack{
                    Text(menuName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    Text(value.undefined ? placeholder : value.description)
                        .foregroundColor(value.undefined ? .gray : .black)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.accentColor)
                        .font(Font.system(size: 20, weight: .bold))
                        .padding(.trailing, 5)
                }
                
                .frame(height: 50)
                Divider()
                    .overlay(.black)
            }
            .background(.white)
        }
}

#Preview {
    DropdownMenu(menuName: "ABF Region", value: .constant(ABFRegions.nordost))
}
