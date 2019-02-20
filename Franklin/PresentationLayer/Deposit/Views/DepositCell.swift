//
//  WalletCell.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class DepositCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.background
        self.topBackgroundView.backgroundColor = Colors.background
        self.topBackgroundView.layer.cornerRadius = 10
        self.date.textColor = Colors.textDarkGray
        self.amount.textColor = Colors.textDarkGray
    }

    func configureCell(model: TableDeposit) {
        date.text = model.date
        amount.text = model.amount + " $"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.date.text = "..."
        self.amount.text = "..."
    }

}
