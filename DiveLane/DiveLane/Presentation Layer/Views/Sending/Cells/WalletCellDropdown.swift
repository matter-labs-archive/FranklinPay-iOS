//
//  WalletCell.swift
//  DiveLane
//
//  Created by NewUser on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class WalletCellDropdown: UITableViewCell {
    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var walletName: UILabel!
    
    func configure(_ wallet: KeyWalletModel) {
        walletAddress.text = wallet.address
        walletName.text = wallet.name
    }
    
}
