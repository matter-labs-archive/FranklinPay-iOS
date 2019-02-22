//
//  ParameterCell.swift
//  DiveLane
//
//  Created by NewUser on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

import UIKit

class ParameterCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func configure(_ parameter: Parameter) {
        typeLabel.text = parameter.type
        valueLabel.text = parameter.value
    }
}
