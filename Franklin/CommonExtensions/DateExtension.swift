//
//  DateExtension.swift
//  Franklin
//
//  Created by Anton on 16/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension Date {
    var timestamp: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
