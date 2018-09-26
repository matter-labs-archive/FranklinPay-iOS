//
//  Colors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class Colors {
    public let mainBackgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    public let mainNavigationBarTintColor = UIColor(displayP3Red: 13/255, green: 92/255, blue: 182/255, alpha: 1)
    public let selectedColor = UIColor.red
    public let deselectedColor = UIColor.lightGray
    
    func changeSelectionColor(dependingOnChoise: Bool) -> UIColor {
        return dependingOnChoise ? self.selectedColor : self.deselectedColor
    }
}
