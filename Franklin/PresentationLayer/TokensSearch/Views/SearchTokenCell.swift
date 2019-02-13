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
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addedIcon.image = UIImage(named: "added")
        self.selectionStyle = .none
    }

    func configure(with token: ERC20Token, isAdded: Bool = false) {
        let title = "\(token.name) (\(token.symbol.uppercased()))"
        self.title.text = title
        addressLabel.text = token.address.hideExtraSymbolsInAddress()
        addedIcon.alpha = isAdded ? 1.0 : 0.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.title.text = ""
        self.addressLabel.text = ""
        self.addedIcon.image = UIImage(named: "added")
        self.addedIcon.alpha = 0.0
    }
}
