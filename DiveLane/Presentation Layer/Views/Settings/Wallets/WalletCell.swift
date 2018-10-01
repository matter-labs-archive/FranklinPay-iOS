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

    weak var delegate: InfoButtonDelegate?
    var wallet: KeyWalletModel?
    let web3SwiftService: IWeb3SwiftService = Web3SwiftService()

    @IBAction func infoButtonPressed(_ sender: UIButton) {
        delegate?.infoButtonPressed(forWallet: wallet!)
    }

    func configureCell(model: KeyWalletModel) {
        wallet = model
        walletName.text = "Name: " + model.name
        walletAddress.text = "Address: " + model.address
        web3SwiftService.getETHbalance(forAddress: model.address) { (balance, error) in
            if let error = error {
                print(error)
            } else {
                self.walletBalance.text = (balance ?? "0") + " ETH"
            }
        }
    }

}

protocol InfoButtonDelegate: class {
    func infoButtonPressed(forWallet wallet: KeyWalletModel)
}
