//
//  FundsCell.swift
//  Franklin
//
//  Created by Anton on 15/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

protocol IFundsDelegate {
    func makeDeposit()
    func makeWithdraw()
}

class FundsCell: UITableViewCell {
    
    var delegate: IFundsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func deposit(_ sender: BasicGreenButton) {
        delegate?.makeDeposit()
    }
    @IBAction func withdraw(_ sender: BasicBlueButton) {
        delegate?.makeWithdraw()
    }
    
}
