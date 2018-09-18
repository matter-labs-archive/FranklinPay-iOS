//
//  TokenCellDropdown.swift
//  DiveLane
//
//  Created by NewUser on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TokenCellDropdown: UITableViewCell {

    @IBOutlet weak var tokenBalance: UILabel!
    @IBOutlet weak var tokenName: UILabel!
    func configure(_ token: ERC20TokenModel) {
        tokenName.text = token.symbol
    }
    
}
