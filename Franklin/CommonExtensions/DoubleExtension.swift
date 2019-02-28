//
//  DoubleExtension.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var stringWithoutZeroFraction: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Double {
    init?(textWithComma text: String) {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        let grade = formatter.number(from: text)
        
        if let doubleGrade = grade?.doubleValue {
            self = doubleGrade
        } else {
            return nil
        }
    }
}
