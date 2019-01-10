//
//  RatesState.swift
//  DiveLane
//
//  Created by Anton Grigorev on 09/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class RatesState {
    
    private static let service = RatesState()
    public var rates = [String: Double]()
    
    public class func shared() -> RatesState {
        return service
    }
    
}
