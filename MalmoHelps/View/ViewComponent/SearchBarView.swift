//
//  SearchBarView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-20.
//

import Foundation
import SwiftUI

struct SearchBarView: View {
    @Binding var keyword: String
    @Binding var searching: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.5))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Searching for...", text: $keyword)
                .autocapitalization(.none)
                
                if searching {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(alignment: .trailing)
                        .padding(.trailing, 13)
                } else {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30,alignment: .trailing)
                        .onTapGesture {
                            keyword = ""
                        }
                        .padding(.trailing, 13)
                }

            }
            .padding(.leading, 13)
        }
        .frame(height: 50)
        .cornerRadius(13)
        .padding()
    }
}
