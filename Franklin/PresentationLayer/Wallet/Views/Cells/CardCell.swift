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
        balance.font = UIFont(name: Constants.CardCell.Balance.font, size: Constants.CardCell.Balance.size)
        balance.textColor = Constants.CardCell.Balance.color
        balanceLabel.font = UIFont(name: Constants.CardCell.BalanceLabel.font, size: Constants.CardCell.BalanceLabel.size)
        balanceLabel.textColor = Constants.CardCell.BalanceLabel.color
        title.font = UIFont(name: Constants.CardCell.Title.font, size: Constants.CardCell.Title.size)
        title.textColor = Constants.CardCell.Title.color
        accountNumber.font = UIFont(name: Constants.CardCell.AccountNumber.font, size: Constants.CardCell.AccountNumber.size)
        accountNumber.textColor = Constants.CardCell.AccountNumber.color
        accountNumberLabel.font = UIFont(name: Constants.CardCell.AccountNumberLabel.font, size: Constants.CardCell.AccountNumberLabel.size)
        accountNumberLabel.textColor = Constants.CardCell.AccountNumberLabel.color
    }

    func configure(token: TableToken) {
        let balanceString = ((token.token.balance ?? "...") + " \(token.token.symbol)")
        let titleString = token.token.isFranklin() ?
            "FRANKLIN" :
            token.token.name.uppercased()
        let accountNumberString = token.inWallet.address.hideExtraSymbolsInAddress()
        
        balance.text = balanceString
        title.text = titleString
        accountNumber.text = accountNumberString
    }

    @IBAction func infoTapped(_ sender: UIButton) {
        delegate?.cardInfoTapped(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        balance.text = "-"
        title.text = "-"
        accountNumber.text = "-"
    }
}
