//
//  FloatingTextField.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-04-08.
//

import Foundation
import SwiftUI

class FloatFormatter: Formatter, ObservableObject {
    private let numberFormatter: NumberFormatter
    
    override init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.isLenient = true
        numberFormatter.maximumFractionDigits = 2
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for value: Any?) -> String? {
        guard let floatValue = value as? Float else {
            return nil
        }
        return numberFormatter.string(from: NSNumber(value: floatValue))
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let floatValue = numberFormatter.number(from: string)?.floatValue {
            obj?.pointee = floatValue as AnyObject
            return true
        } else {
            error?.pointee = "Invalid number" as NSString
            return false
        }
    }
}

struct FloatingTextField: View {
    @Binding var floatValue: Float
    let placeholder: String
    @StateObject private var formatter = FloatFormatter()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray, lineWidth: 1)
            .frame(width: 60, height: 40)
            .overlay(
        TextField(placeholder, value: $floatValue, formatter: formatter)
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .font(Font.system(size: 22, weight: .bold))
            .multilineTextAlignment(.center)
        )
    }
}

struct FloatingTextField_Previews: PreviewProvider {
    static var previews: some View {
        FloatingTextField(floatValue: .constant(1.5), placeholder: "1.0")
    }
}

