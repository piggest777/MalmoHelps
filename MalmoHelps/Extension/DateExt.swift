//
//  DateExt.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-27.
//

import Foundation

extension Date {
    func toString(format: String = "yy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
