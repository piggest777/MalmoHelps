//
//  AnimatedHideCalendar.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-10-23.
//

import SwiftUI

struct AnimatedHideCalendar: View {
    @State private var isMonthlyPickerVisible = false
    @Binding var currentDate: Date
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if isMonthlyPickerVisible {
                    YearMonthPickerView(selectedDate: $currentDate, isPresented: $isMonthlyPickerVisible)
                        .transition(.opacity)
                } else {
                    HStack {
                        Spacer()
                        Button {
                            let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)
                            currentDate = previousMonth!
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        Text("\(currentDate.monthName()) \(currentDate.yearAsString)")
                            .font(.headline)
                        Button {
                            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
                            currentDate = nextMonth!
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        Spacer()

                    }
                }
            
            }
            .padding()
            
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        isMonthlyPickerVisible.toggle()
                    }
                } label: {
                    Text(isMonthlyPickerVisible ? "" : "Show")
                        .foregroundStyle(Color("ButtonColor"))
                }.padding(.trailing, 20)
            }

        }
    }
}

#Preview {
    AnimatedHideCalendar(currentDate: .constant(Date()))
}
