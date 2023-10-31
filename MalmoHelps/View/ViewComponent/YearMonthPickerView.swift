//
//  YearMonthPickerView.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-23.
//

import SwiftUI

struct YearMonthPickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    let months: [String] = Calendar.current.shortMonthSymbols
    let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
    
    var body: some View {
        VStack {
            //year picker
            HStack {
                Image(systemName: "chevron.left")
                    .frame(width: 24.0)
                    .onTapGesture {
                        var dateComponent = DateComponents()
                        dateComponent.year = -1
                        selectedDate = Calendar.current.date(byAdding: dateComponent, to: selectedDate)!
                        print(selectedDate)
                    }
                
                Text(String(selectedDate.year))
                         .fontWeight(.bold)
                         .transition(.move(edge: .trailing))
                
                Image(systemName: "chevron.right")
                    .frame(width: 24.0)
                    .onTapGesture {
                        var dateComponent = DateComponents()
                        dateComponent.year = 1
                        selectedDate = Calendar.current.date(byAdding: dateComponent, to: selectedDate)!
                        print(selectedDate)
                    }
            }.padding(15)
            
            //month picker
            LazyVGrid(columns: columns, spacing: 20) {
               ForEach(months, id: \.self) { item in
                    Text(item)
                       .foregroundStyle(item == selectedDate.monthName() ?  .white : .black)
                    .font(.headline)
                    .frame(width: 60, height: 33)
                    .background(item == selectedDate.monthName() ?  Color("ButtonColor") : .white)
                    .cornerRadius(8)
                    .onTapGesture {
                        var dateComponent = DateComponents()
                        dateComponent.day = 1
                        dateComponent.month =  months.firstIndex(of: item)! + 1
                        dateComponent.year = Int(selectedDate.year)
                        selectedDate = Calendar.current.date(from: dateComponent)!
                        isPresented = false
                    }
               }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    YearMonthPickerView(selectedDate: .constant(Date()), isPresented: .constant(true))
}

