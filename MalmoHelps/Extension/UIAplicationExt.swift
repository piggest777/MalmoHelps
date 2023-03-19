//
//  UIAplicationExt.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-03-20.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
