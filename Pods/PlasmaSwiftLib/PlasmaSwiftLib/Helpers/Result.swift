//
//  Result.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Error(Error)
}
