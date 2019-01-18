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

    @IBOutlet weak var param: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var settingIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.firstMain
        self.topBackgroundView.backgroundColor = Colors.secondMain
        self.topBackgroundView.layer.cornerRadius = 10
        self.param.textColor = Colors.textFirst
        self.param.font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
        self.value.textColor = Colors.textSecond
        self.value.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
    }

    func configure(setting: MainSetting) {
        self.settingIcon.image = setting.image
        self.param.text = setting.title
        var val: String?
        if let netVal = setting.currentState as? Web3Network {
            val = netVal.name
        }
        if let walVal = setting.currentState as? Wallet {
            val = walVal.name
        }
        guard let v = val else {return}
        self.value.text = v
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.param.text = ""
        self.value.text = ""
    }
}
