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

class TokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var balanceInDollars: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var usdRate: UILabel!
    @IBOutlet weak var hoursStat: UILabel!
    
    var link: WalletViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.firstMain
        self.topBackgroundView.backgroundColor = Colors.secondMain
        self.topBackgroundView.layer.cornerRadius = 10
        self.title.textColor = Colors.textFirst
        self.balanceInDollars.textColor = Colors.textSecond
        self.balance.textColor = Colors.textFirst
        self.rate.textColor = Colors.active
        self.usdRate.textColor = Colors.textSecond
        self.hoursStat.textColor = Colors.textSecond
    }

    func configure(token: TableToken) {
        let balance = token.balance ?? "-"
        let balanceInDollars = "$" + (token.balanceInDollars ?? "-")
        let title = "\(token.token.name) (\(token.token.symbol.uppercased()))"
        
        self.title.text = title
        self.balanceInDollars.text = balanceInDollars
        self.balance.text = balance
        self.rate.text = (token.token.rate != nil) ? ("$" + String(token.token.rate!)) : "-"
        //self.changeSelectButton(isSelected: isSelected)
    }

//    func changeSelectButton(isSelected: Bool) {
//
//        let button = selectButton(isSelected: isSelected)
//        button.addTarget(self, action: #selector(handleMarkAsSelected), for: .touchUpInside)
//
//        accessoryView = button
//    }

//    @objc private func handleMarkAsSelected() {
//        if isPlasma {
//            link?.selectUTXO(cell: self)
//        } else {
//            link?.selectToken(cell: self)
//        }
//    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = "-"
        self.balanceInDollars.text = "-"
        self.balance.text = "-"
        self.rate.text = "-"
    }
}
