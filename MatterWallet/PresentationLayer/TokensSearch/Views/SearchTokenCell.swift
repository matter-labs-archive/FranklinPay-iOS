//
//  SearchTokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

import Web3swift
import EthereumAddress

class SearchTokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var usdRate: UILabel!
    @IBOutlet weak var hoursStat: UILabel!
    @IBOutlet weak var hoursStatProc: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.firstMain
        self.topBackgroundView.backgroundColor = Colors.secondMain
        self.topBackgroundView.layer.cornerRadius = 10
        self.title.textColor = Colors.textFirst
        self.title.font = UIFont(name: Constants.font, size: Constants.basicFontSize) ?? UIFont.systemFont(ofSize: Constants.basicFontSize)
        self.addressLabel.textColor = Colors.textFirst
        self.addressLabel.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.rate.textColor = Colors.active
        self.rate.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.usdRate.textColor = Colors.textSecond
        self.usdRate.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
        self.hoursStat.textColor = Colors.textSecond
        self.hoursStat.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
        self.hoursStatProc.textColor = Colors.textSecond
        self.hoursStatProc.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.addedIcon.image = UIImage(named: "added")
        
        self.selectionStyle = .none
    }

    func configure(with token: ERC20Token, isAdded: Bool = false) {
        let title = "\(token.name) (\(token.symbol.uppercased()))"
        
        self.title.text = title
        self.rate.text = (token.rate != nil) ? ("$" + String(token.rate!)) : "-"
        self.hoursStatProc.text = (token.change24 != nil) ? (String(token.change24!) + "%") : "-"
        self.hoursStatProc.textColor = (token.change24 ?? 0.0) < 0.0 ? Colors.negative : Colors.positive
        
        addressLabel.text = token.address.hideExtraSymbolsInAddress()
        addedIcon.alpha = isAdded ? 1.0 : 0.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.title.text = ""
        self.rate.text = "-"
        self.hoursStatProc.text = "-"
        self.addressLabel.text = ""
        self.addedIcon.image = UIImage(named: "added")
        self.addedIcon.alpha = 0.0
    }
}
