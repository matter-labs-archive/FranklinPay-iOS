//
//  WalletViewController+FundsDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletViewController: IFundsDelegate {
    func makeDeposit() {
        print("deposit")
    }
    
    func makeWithdraw() {
        print("withdraw")
    }
}
