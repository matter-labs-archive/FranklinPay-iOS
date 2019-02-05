//
//  TokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress

protocol TokenCellDelegate : class {
    func tokenInfoTapped(_ sender: TokenCell)
}

class TokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var middleBackgroundView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNumber: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    
    weak var delegate: TokenCellDelegate?
    
    override func awakeFromNib() {
        self.balance.font = UIFont(name: Constants.TokenCell.Balance.font, size: Constants.TokenCell.Balance.size)
        self.balance.textColor = Constants.TokenCell.Balance.color
        self.balanceLabel.font = UIFont(name: Constants.TokenCell.BalanceLabel.font, size: Constants.TokenCell.BalanceLabel.size)
        self.balanceLabel.textColor = Constants.TokenCell.BalanceLabel.color
        self.title.font = UIFont(name: Constants.TokenCell.Title.font, size: Constants.TokenCell.Title.size)
        self.title.textColor = Constants.TokenCell.Title.color
        self.accountNumber.font = UIFont(name: Constants.TokenCell.AccountNumber.font, size: Constants.TokenCell.AccountNumber.size)
        self.accountNumber.textColor = Constants.TokenCell.AccountNumber.color
        self.accountNumberLabel.font = UIFont(name: Constants.TokenCell.AccountNumberLabel.font, size: Constants.TokenCell.AccountNumberLabel.size)
        self.accountNumberLabel.textColor = Constants.TokenCell.AccountNumberLabel.color
    }

    func configure(token: TableToken) {
        let balance = token.token.isFranklin() ? ("$ " + (token.token.balance ?? "-")) : (token.token.balance ?? "-")
        let title = token.token.isFranklin() ? token.token.name.uppercased() : ("\(token.token.name) (\(token.token.symbol.uppercased()))")
        let accountNumber = token.token.walletAddress?.hideExtraSymbolsInAddress()
        
        self.balance.text = balance
        self.title.text = title
        self.accountNumber.text = accountNumber
    }

    @IBAction func infoTapped(_ sender: UIButton) {
        delegate?.tokenInfoTapped(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.balance.text = "-"
        self.title.text = "-"
        self.accountNumber.text = "-"
    }
}
