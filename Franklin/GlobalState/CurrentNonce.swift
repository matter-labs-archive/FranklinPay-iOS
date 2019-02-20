//
//  CurrentNonce.swift
//  Franklin
//
//  Created by Anton on 13/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import BigInt

public class CurrentNonce {
    
    private static var _currentNonce: BigUInt?
    
    public class var currentNonce: BigUInt? {
        get {
            if let nonce = _currentNonce {
                return nonce
            } else {
                return 0
            }
        }
        set(nonce) {
            if let nonce = nonce {
                _currentNonce = nonce
            } else {
                _currentNonce = 0
            }
        }
    }
    
}
