//
//  DateExt.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import Foundation

extension Date {
    func toString(format: String = "dd-MM-yy") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func toMonthDayString(format: String = "dd MMM") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
