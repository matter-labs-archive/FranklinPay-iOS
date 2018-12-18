//
//  WalletCell.swift
//  DiveLane
//
//  Created by NewUser on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import EthereumAddress

class WalletCellDropdown: UITableViewCell {
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var walletName: UILabel!

    let web3SwiftService = Web3Service()
    var currentWallet: WalletModel?

    func configure(_ wallet: WalletModel) {
        currentWallet = wallet
        walletAddress.text = wallet.address.hideExtraSymbolsInAddress()
        walletName.text = wallet.name
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
