//
//  Colors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

struct Colors {
    struct BackgroundColors {
        static let main = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    }
    
    struct NavBarColors {
        static let mainTint = UIColor(displayP3Red: 13/255, green: 92/255, blue: 182/255, alpha: 1)
    }
    
    struct ButtonColors {
        static let selectedColor = UIColor.red
        static let deselectedColor = UIColor.lightGray
        
        func changeSelectionColor(dependingOnChoise: Bool) -> UIColor {
            return dependingOnChoise ? Colors.ButtonColors.selectedColor : Colors.ButtonColors.deselectedColor
        }
    }
    
    
}
