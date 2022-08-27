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
        for i in 1...self.count {
            sequences.append(String(self.prefix(i)).lowercased())
        }
        return sequences
    }
}
