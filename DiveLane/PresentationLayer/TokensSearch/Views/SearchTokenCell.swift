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
        self.addressLabel.textColor = Colors.textFirst
        self.rate.textColor = Colors.active
        self.usdRate.textColor = Colors.textSecond
        self.hoursStat.textColor = Colors.textSecond
        self.addedIcon.image = UIImage(named: "added")
    }

    func configure(with token: ERC20Token, isAdded: Bool = false) {
        let title = "\(token.name) (\(token.symbol.uppercased()))"
        
        self.title.text = title
        self.rate.text = (token.rate != nil) ? ("$" + String(token.rate!)) : "-"
        
        addressLabel.text = token.address
        addedIcon.alpha = isAdded ? 1.0 : 0.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.title.text = ""
        self.rate.text = "-"
        self.addressLabel.text = ""
        self.addedIcon.image = UIImage(named: "added")
        self.addedIcon.alpha = 0.0
    }
}
