//
//  UTXOCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 26.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import PlasmaSwiftLib
import web3swift

class UTXOCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var balanceInDollarsLabel: UILabel!

    func configureForPlasmaBlockchain(utxo: ListUTXOsModel, token: ERC20TokenModel = ERC20TokenModel(isEther: true), forWallet: KeyWalletModel) {
        let balance = Web3Utils.formatToEthereumUnits(utxo.value,
                                                      toUnits: .eth,
                                                      decimals: 6,
                                                      decimalSeparator: ".")
        self.balanceLabel.text = balance
        self.updateBalanceInDollars(for: token, withBalance: balance)
    }

    func updateBalanceInDollars(for token: ERC20TokenModel, withBalance: String?) {
        TokensService().updateConversion(for: token, completion: { (conversion) in
            DispatchQueue.main.async { [weak self] in
                let conv: Double = conversion ?? 0
                let resultInDouble: Double = Double(withBalance ?? "0") ?? 0
                let convertedAmount = Double(round(100*(conv * resultInDouble))/100)
                let stringAmount =  String(convertedAmount)
                self?.balanceInDollarsLabel.text = stringAmount + "$"
            }
        })
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.balanceLabel.text = ""
        self.tokenNameLabel.text = ""
        self.balanceInDollarsLabel.text = ""
    }
}
