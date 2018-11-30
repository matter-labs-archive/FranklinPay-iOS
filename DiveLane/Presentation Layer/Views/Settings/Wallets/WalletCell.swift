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

    var wallet: WalletModel?
    let web3SwiftService = Web3Service()

    func configureCell(model: WalletModel) {
        wallet = model
        walletName.text = "Wallet " + model.name
        walletAddress.text = "Address: " + model.address.hideExtraSymbolsInAddress()
        do {
            let balance = try web3SwiftService.getETHbalance(for: model)
            self.walletBalance.text = balance + " ETH"
        } catch let error {
            self.walletBalance.text = error.localizedDescription
        }
    }

}
