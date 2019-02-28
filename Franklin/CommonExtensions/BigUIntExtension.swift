//
//  BigUIntExtension.swift
//  Franklin
//
//  Created by Anton on 28/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt

extension BigUInt {
    
    var getConvinientRepresentationBalance: String {
        let str = Web3.Utils.formatToPrecision(self, numberDecimals: 18, formattingDecimals: 6, decimalSeparator: ".", fallbackToScientific: true) ?? "0"
        let dbl: Double = Double(str) ?? 0
        return dbl.stringWithoutZeroFraction
    }
    
    var getConvenientRepresentationPlasmaBalance: String {
        let string = (Double(self)/1000000).stringWithoutZeroFraction
        return string
    }
}
