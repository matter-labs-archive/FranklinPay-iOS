//
//  TokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class TokenCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var tokenShortName: UILabel!
    @IBOutlet weak var tokenIcon: UIImageView!
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var tokenAddress: UILabel!
    
    let keysService: KeysService = KeysService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(token: ERC20TokenModel?, forWallet: String) {
        
        guard let token = token else {
            return
        }
        
        let walletName = LocalDatabase().getWallet()?.name
        self.walletName.text = walletName
        self.tokenShortName.text = token.symbol.uppercased()
        
        if token == ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth") {
            self.tokenAddress.text = forWallet
            Web3SwiftService().getETHbalance() { (result, error) in
                DispatchQueue.main.async {
                    self.balance.text = result ?? ""
                }
            }
        } else {
            self.tokenAddress.text = token.address
            Web3SwiftService().getERCBalance(for: token.address, address: forWallet) { (result, error) in
                guard let result = result else {return}
                self.balance.text = result
            }
        }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.balance.text = ""
        self.tokenShortName.text = ""
        self.walletName.text = ""
        self.tokenAddress.text = ""
        self.tokenIcon.image = UIImage(named: "ether")
    }
}
