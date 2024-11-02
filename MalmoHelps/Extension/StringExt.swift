//
//  StringExt.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import Foundation

extension String {
    func generateStringSequence() -> [String] {
        /// E.g) "Mark" yields "M", "Ma", "Mar", "Mark"
        var sequences: [String] = []
        if !self.isEmpty {
            for i in 1...self.count {
                sequences.append(String(self.prefix(i)).lowercased())
        }

        }
        return sequences
    }
    
    func fromString(format: String = "dd-MM-yy") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "sv_SE")

        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            print("Invalid date format")
            return nil
        }
    }
    
    func trimSpaces() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String: DropdownData {
    
    var description: String {
        return self
    }

    var isUndefined: Bool {
        return self.isEmpty
    }
}
