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
    @IBOutlet weak var hoursStatProc: UILabel!
    
    var link: WalletViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.firstMain
        self.topBackgroundView.backgroundColor = Colors.secondMain
        self.topBackgroundView.layer.cornerRadius = 10
        self.title.textColor = Colors.textFirst
        self.title.font = UIFont(name: Constants.font, size: Constants.basicFontSize) ?? UIFont.systemFont(ofSize: Constants.basicFontSize)
        self.balanceInDollars.textColor = Colors.textSecond
        self.balanceInDollars.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.balance.textColor = Colors.textFirst
        self.balance.font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
        self.rate.textColor = Colors.active
        self.rate.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.usdRate.textColor = Colors.textSecond
        self.usdRate.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
        self.hoursStat.textColor = Colors.textSecond
        self.hoursStat.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
        self.hoursStatProc.textColor = Colors.textSecond
        self.hoursStatProc.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
    }

    func configure(token: TableToken) {
        let balance = token.token.balance ?? "-"
        let balanceInDollars = "$" + (token.token.usdBalance ?? "-")
        let title = "\(token.token.name) (\(token.token.symbol.uppercased()))"
        
        self.title.text = title
        self.balanceInDollars.text = balanceInDollars
        self.balance.text = balance
        self.rate.text = (token.token.rate != nil) ? ("$" + String(token.token.rate!)) : "-"
        self.hoursStatProc.text = (token.token.change24 != nil) ? (String(token.token.change24!) + "%") : "-"
        self.hoursStatProc.textColor = (token.token.change24 ?? 0.0) < 0.0 ? Colors.negative : Colors.positive
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
        self.hoursStatProc.text = "-"
    }
}
