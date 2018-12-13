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
    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var walletName: UILabel!

    let web3SwiftService = Web3Service()
    var currentWallet: WalletModel?

    func configure(_ wallet: WalletModel) {
        currentWallet = wallet
        walletAddress.text = wallet.address.hideExtraSymbolsInAddress()
        walletName.text = wallet.name
        do {
            if let token = CurrentToken.currentToken {
                let balance = try
                    web3SwiftService.getERC20balance(for: wallet,
                                                     token: token)
                if let currentAddress = self.currentWallet?.address, currentAddress == wallet.address {
                    self.walletBalance.text = balance + " " + (CurrentToken.currentToken?.symbol.uppercased() ?? "")
                }
            } else {
                let balance = try web3SwiftService.getETHbalance(for: wallet)
                if let currentAddress = self.currentWallet?.address, currentAddress == wallet.address {
                    self.walletBalance.text = balance + " ETH"
                }
            }
        } catch {
            return
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        walletBalance.text = "Loading..."
    }

}
