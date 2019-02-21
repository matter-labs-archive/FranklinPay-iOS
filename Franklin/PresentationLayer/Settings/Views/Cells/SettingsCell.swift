//
//  SettingsCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

class SettingsCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var settingIcon: UIImageView!
    @IBOutlet weak var markerIcon: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    func configure(setting: SettingsModel) {
        settingIcon.image = setting.image
        title.text = setting.title
        subtitle.text = setting.subtitle
        if setting.subtitle == nil {
            heightConstraint.constant = 0
        } else {
            heightConstraint.constant = 15
        }
        markerIcon.alpha = setting.notification ? 1 : 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = ""
        subtitle.text = ""
        markerIcon.alpha = 0
    }
}
