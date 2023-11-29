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

extension Date {
    var year: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    func monthName(format: String = "MMM") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    func monthAsInt() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    func yearAsInt() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    
    var yearAsString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    init?(year: Int, month: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1  // Set to the first day of the month

        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            self = date
        } else {
            return nil
        }
    }
}

