//
//  CardCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress

protocol CardCellDelegate : class {
    func cardInfoTapped(_ sender: CardCell)
}

class CardCell: UITableViewCell {

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
    
    weak var delegate: CardCellDelegate?
    
    override func awakeFromNib() {
        self.balance.font = UIFont(name: Constants.CardCell.Balance.font, size: Constants.CardCell.Balance.size)
        self.balance.textColor = Constants.CardCell.Balance.color
        self.balanceLabel.font = UIFont(name: Constants.CardCell.BalanceLabel.font, size: Constants.CardCell.BalanceLabel.size)
        self.balanceLabel.textColor = Constants.CardCell.BalanceLabel.color
        self.title.font = UIFont(name: Constants.CardCell.Title.font, size: Constants.CardCell.Title.size)
        self.title.textColor = Constants.CardCell.Title.color
        self.accountNumber.font = UIFont(name: Constants.CardCell.AccountNumber.font, size: Constants.CardCell.AccountNumber.size)
        self.accountNumber.textColor = Constants.CardCell.AccountNumber.color
        self.accountNumberLabel.font = UIFont(name: Constants.CardCell.AccountNumberLabel.font, size: Constants.CardCell.AccountNumberLabel.size)
        self.accountNumberLabel.textColor = Constants.CardCell.AccountNumberLabel.color
    }

    func configure(token: TableToken) {
        let balance = ((token.token.balance ?? "...") + " \(token.token.symbol)")
        let title = token.token.isFranklin() ?
            "FRANKLIN" :
            token.token.name.uppercased()
        let accountNumber = token.inWallet.address.hideExtraSymbolsInAddress()
        
        self.balance.text = balance
        self.title.text = title
        self.accountNumber.text = accountNumber
    }

    @IBAction func infoTapped(_ sender: UIButton) {
        delegate?.cardInfoTapped(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.balance.text = "-"
        self.title.text = "-"
        self.accountNumber.text = "-"
    }
}
