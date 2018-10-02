//
//  TokenInfoCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 02.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TokenInfoCell: UITableViewCell {

    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var measurementLabel: UILabel!

    func configure(with parameter: String?, value: String?, measurment: String?) {
        paramLabel.text = parameter ?? ""
        valueLabel.text = value ?? ""
        measurementLabel.text = measurment ?? ""
    }

}
