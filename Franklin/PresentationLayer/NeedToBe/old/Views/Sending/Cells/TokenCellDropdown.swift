//
//  TokenCellDropdown.swift
//  DiveLane
//
//  Created by NewUser on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress

class TokenCellDropdown: UITableViewCell {

    @IBOutlet weak var tokenBalance: UILabel!
    @IBOutlet weak var tokenName: UILabel!

    let web3Service = Web3Service()
    var currentToken: ERC20TokenModel?
    var currentUTXO: PlasmaUTXOs?

    func configure(_ token: ERC20TokenModel, wallet: WalletModel) {
        currentToken = token
        tokenName.text = token.name
        let balance: String
        if token == ERC20TokenModel(isEther: true) {
            if let result = try? web3Service.getETHbalance(for: wallet) {
                balance = result
                if let currentAddress = self.currentToken?.address, currentAddress == token.address {
                    DispatchQueue.main.async {
                        self.tokenBalance.text = "Balance: " + balance + " " + token.symbol.uppercased()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tokenBalance.text = "Can't get balance for \(token.name)"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tokenBalance.text = "Can't get balance for \(token.name)"
                }
            }
        } else {
            if let result = try? web3Service.getERC20balance(for: wallet, token: token) {
                balance = result
                if let currentAddress = self.currentToken?.address, currentAddress == token.address {
                    DispatchQueue.main.async {
                        self.tokenBalance.text = "Balance: " + balance + " " + token.symbol.uppercased()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tokenBalance.text = "Can't get balance for \(token.name)"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tokenBalance.text = "Can't get balance for \(token.name)"
                }
            }
        }
    }

    func configure(_ utxo: PlasmaUTXOs, wallet: WalletModel) {
        currentUTXO = utxo
        tokenName.text = ""
        let balance = Web3Utils.formatToEthereumUnits(utxo.value,
                                                      toUnits: .eth,
                                                      decimals: 6,
                                                      decimalSeparator: ".")
        self.tokenBalance.text = balance
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tokenBalance.text = "Loading..."
    }
}
