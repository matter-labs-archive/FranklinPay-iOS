//
//  SelectButton.swift
//  DiveLane
//
//  Created by Anton Grigorev on 30.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

func selectButton(isSelected: Bool) -> UIButton {
    let button = UIButton(type: .system)
    let name = isSelected ? "SuccessIcon" : "deselected"
    button.setImage(UIImage(named: name), for: .normal)
    button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    return button
}
