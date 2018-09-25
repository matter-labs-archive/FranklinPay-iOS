//
//  PincodeCreationStatus.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

enum PincodeCreationStatus: String {
    case new = "Enter a pincode"
    case verify = "Verify your new pincode"
    case ready = "Ready"
    case wrong = "Wrong pincode"
}
