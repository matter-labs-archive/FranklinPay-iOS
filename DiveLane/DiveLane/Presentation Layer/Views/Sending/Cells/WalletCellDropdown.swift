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
    
    func configure(_ wallet: KeyWalletModel) {
        walletAddress.text = wallet.address
        walletName.text = wallet.name
        if let tokenAddress = CurrentToken.currentToken?.address, !tokenAddress.isEmpty {
            web3SwiftService.getERCBalance(for: CurrentToken.currentToken?.address ?? "", address: wallet.address) { (balance, error) in
                if let error = error {
                    print(error)
                } else {
                    self.walletBalance.text = (balance ?? "0") + " " + (CurrentToken.currentToken?.symbol.uppercased() ?? "")
                }
            }
        } else {
            web3SwiftService.getETHbalance(forAddress: wallet.address) { (balance, error) in
                if let error = error {
                    print(error)
                } else {
                    self.walletBalance.text = (balance ?? "0") + " ETH"
                }
            }
        }
        
        
    }
    
}
