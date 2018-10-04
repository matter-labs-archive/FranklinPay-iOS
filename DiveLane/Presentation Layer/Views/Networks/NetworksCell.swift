//
//  NetworksCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class NetworksCell: UITableViewCell {

    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var successIcon: UIImageView!

    func configure(network: Networks, isChosen: Bool = false) {
        var name: String?
        switch network {
        case .Mainnet:
            name = "Mainnet"
        case .Rinkeby:
            name = "Rinkeby"
        case .Kovan:
            name = "Kovan"
        default:
            name = "Ropsten"
        }
        self.networkLabel.text = name ?? ""
        successIcon.alpha = isChosen ? 1.0 : 0.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        successIcon.alpha = 0.0
        self.networkLabel.text = ""
    }

}
