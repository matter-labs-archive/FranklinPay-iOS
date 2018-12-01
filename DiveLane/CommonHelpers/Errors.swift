//
//  CommonErrors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 29/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct Errors {
    public enum CommonErrors: Error {
        case wrongPassword
        case unknown
    }
}
