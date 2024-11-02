//
//  DocumentType.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2024-10-14.
//


enum DocumentType: String, CaseIterable, DropdownData {
    
    var description: String {
        self.rawValue
    }
    
    var isUndefined: Bool {
        return self == .undefined
    }
    
    case swedishCitizenship = "Swedish citizenship"
    case swedishPersonnummer = "Swedish personnumer"
    case massflyktdirektiv = "Massflyktdirektiv"
    case asylum = "asyl"
    case noDocs = "no docs"
    case undefined
    
    static func documentType(from description: String) -> DocumentType {
        return DocumentType(rawValue: description) ?? .undefined
    }
}
