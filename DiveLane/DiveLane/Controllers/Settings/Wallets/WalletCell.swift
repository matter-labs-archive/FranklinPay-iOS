//
//  WalletCell.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class WalletCell: UITableViewCell {
    
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: KeyWalletModel) {
        walletName.text = "Name: " + model.name
        walletAddress.text = "Address: " + model.address
    }
    
}
