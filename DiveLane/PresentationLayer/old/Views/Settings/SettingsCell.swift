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

    func configure(param: String, value: Any) {
        self.param.text = param
        let name: String?
        switch param {
        case "Network":
            let network = value as? Networks
            switch network {
            case .Mainnet?:
                name = "Mainnet"
            case .Kovan?:
                name = "Kovan"
            case .Ropsten?:
                name = "Ropsten"
            default:
                name = "Rinkeby"
            }
        default:
            let wallet = (value as? String) ?? "No name"
            name = wallet
        }
        self.value.text = name ?? ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.param.text = ""
        self.value.text = ""
    }
}
