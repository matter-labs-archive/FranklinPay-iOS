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

    let web3SwiftService = Web3SwiftService()
    var currentWallet: KeyWalletModel?

    func configure(_ wallet: KeyWalletModel) {
        currentWallet = wallet
        walletAddress.text = wallet.address
        walletName.text = wallet.name
        if let tokenAddress = CurrentToken.currentToken?.address, !tokenAddress.isEmpty {
            web3SwiftService.getERCBalance(for: CurrentToken.currentToken?.address ?? "", address: wallet.address) { (balance, error) in
                if let error = error {
                    print(error)
                } else {
                    if let currentAddress = self.currentWallet?.address, currentAddress == wallet.address {
                        self.walletBalance.text = (balance ?? "0") + " " + (CurrentToken.currentToken?.symbol.uppercased() ?? "")
                    }
                }
            }
        } else {
            web3SwiftService.getETHbalance(forAddress: wallet.address) { (balance, error) in
                if let error = error {
                    print(error)
                } else {
                    if let currentAddress = self.currentWallet?.address, currentAddress == wallet.address {
                        self.walletBalance.text = (balance ?? "0") + " ETH"
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        walletBalance.text = "Loading..."
    }

}
