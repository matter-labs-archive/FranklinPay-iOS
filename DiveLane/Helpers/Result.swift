//
//  Result.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public enum Result<T> {
    case Success(T)
    case Error(Error)
}
