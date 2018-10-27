//
//  CurrentUTXO.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import PlasmaSwiftLib

class CurrentUTXO {
    
    static var _currentUTXO: ListUTXOsModel?
    
    class var currentUTXO: ListUTXOsModel? {
        get {
            
            if _currentUTXO == nil {
                _currentUTXO = ListUTXOsModel(json: ["blockNumber" : 1,
                                                     "transactionNumber" : 0,
                                                     "outputNumber" : 0,
                                                     "value" : 50])
            }
            return _currentUTXO
        }
        
        set(token) {
            
            _currentUTXO = token
        }
    }
    
}
