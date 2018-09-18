//
//  TokenCellDropdown.swift
//  DiveLane
//
//  Created by NewUser on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TokenCellDropdown: UITableViewCell {

    @IBOutlet weak var tokenBalance: UILabel!
    @IBOutlet weak var tokenName: UILabel!
    
    let web3Service = Web3SwiftService()
    func configure(_ token: ERC20TokenModel, wallet: KeyWalletModel) {
        tokenName.text = token.name
        web3Service.getERCBalance(for: token.address, address: wallet.address) { (balance, error) in
            if error != nil {
                self.web3Service.getETHbalance(forAddress: wallet.address, completion: { (balance, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.tokenBalance.text = "Balance: " + (balance ?? "0") + " " + token.symbol.uppercased()
                    }
                })
            } else {
                self.tokenBalance.text = "Balance: " + (balance ?? "0") + " " + token.symbol.uppercased()
            }
        }
    }
    
}
