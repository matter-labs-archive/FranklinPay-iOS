//
//  FloatExtension.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public extension Float {
    func roundToDecimals(decimals: Int = 2) -> Float {
        let multiplier = Float(10 ^ decimals)
        return (multiplier * self).rounded() / multiplier
    }
}
