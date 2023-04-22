//
//  PDFManager.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-21.
//

import Foundation
import TPPDF


class PDFManager {
    
    static let shared = PDFManager()
    
    func createTestPDF() -> URL? {
        let document = PDFDocument(format: .a4)
        document.add(.contentCenter, text: "Create PDF documents easily.")
        let generator = PDFGenerator(document: document)
        let url = try? generator.generateURL(filename: "Example.pdf")
        return url
    }
    
}
