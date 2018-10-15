//
//  SearchTokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class SearchTokenCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tokenIcon: UIImageView!
    @IBOutlet weak var addedIcon: UIImageView!

    func configure(with token: ERC20TokenModel, isAdded: Bool = false) {
        nameLabel.text = token.name + " (\(token.symbol))"
        //tokenIcon.image =
        addressLabel.text = token.address
        addedIcon.alpha = isAdded ? 1.0 : 0.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = ""
        self.addressLabel.text = ""
        self.tokenIcon.image = UIImage(named: "ether")
        self.addedIcon.alpha = 0.0
    }
}
