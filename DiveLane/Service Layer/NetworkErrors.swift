//
//  NetworkErrors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 28/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

extension Errors {
    public enum NetworkErrors: Error {
        case wrongURL
        case wrongJSON
        case noSuchAPIOnTheEtherscan
        case noData
    }
}
