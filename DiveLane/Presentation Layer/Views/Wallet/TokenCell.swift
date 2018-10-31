//
//  TokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift
import PlasmaSwiftLib

class TokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var tokenShortName: UILabel!
    @IBOutlet weak var tokenIcon: UIImageView!
    @IBOutlet weak var tokenAddress: UILabel!
    @IBOutlet weak var balanceInDollars: UILabel!

    var link: WalletViewController?
    var isPlasma: Bool = false

    let keysService: KeysService = KeysService()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureForEtherBlockchain(token: ERC20TokenModel?, forWallet: KeyWalletModel, isSelected: Bool) {
        guard let token = token else {return}
        isPlasma = false
        self.tokenShortName.text = token.symbol.uppercased()
        updateBalanceAndAddress(for: token, forWallet: forWallet)
        changeSelectButton(isSelected: isSelected)
    }

    func configureForPlasmaBlockchain(utxo: ListUTXOsModel, token: ERC20TokenModel = ERC20TokenModel(isEther: true), forWallet: KeyWalletModel) {
        let balance = Web3Utils.formatToEthereumUnits(utxo.value,
                                                      toUnits: .eth,
                                                      decimals: 6,
                                                      decimalSeparator: ".")
        isPlasma = true
        self.balance.text = balance
        self.tokenShortName.text = "ETH"
        self.tokenAddress.text = "Wallet address: \(forWallet.address.hideExtraSymbolsInAddress())"
        self.updateBalanceInDollars(for: token, withBalance: balance)
        changeSelectButton(isSelected: false)
    }

    func changeSelectButton(isSelected: Bool) {

        let button = selectButton(isSelected: isSelected)
        button.addTarget(self, action: #selector(handleMarkAsSelected), for: .touchUpInside)

        accessoryView = button
    }

    func updateBalanceAndAddress(for token: ERC20TokenModel, forWallet: KeyWalletModel) {
        if token == ERC20TokenModel(isEther: true) {
            self.tokenAddress.text = "Wallet address: \(forWallet.address.hideExtraSymbolsInAddress())"
            Web3SwiftService().getETHbalance(for: forWallet) { [weak self] (result, _) in
                DispatchQueue.main.async {
                    self?.balance.text = result ?? "0"
                    self?.updateBalanceInDollars(for: token, withBalance: result)
                }
            }
        } else {
            self.tokenAddress.text = "Token address: \(token.address.hideExtraSymbolsInAddress())"
            Web3SwiftService().getERCBalance(for: token.address,
                                             address: forWallet.address) { [weak self] (result, _) in
                DispatchQueue.main.async {
                    self?.balance.text = result ?? "0"
                    self?.updateBalanceInDollars(for: token, withBalance: result)
                }
            }
        }
    }

    func updateBalanceInDollars(for token: ERC20TokenModel, withBalance: String?) {
        TokensService().updateConversion(for: token, completion: { (conversion) in
            DispatchQueue.main.async { [weak self] in
                let conv: Double = conversion ?? 0
                let resultInDouble: Double = Double(withBalance ?? "0") ?? 0
                let convertedAmount = Double(round(100*(conv * resultInDouble))/100)
                let stringAmount =  String(convertedAmount)
                self?.balanceInDollars.text = stringAmount + "$"
            }
        })
    }

    @objc private func handleMarkAsSelected() {
        if isPlasma {
            link?.selectUTXO(cell: self)
        } else {
            link?.selectToken(cell: self)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.balance.text = ""
        self.tokenShortName.text = ""
        self.tokenAddress.text = ""
        self.tokenIcon.image = UIImage(named: "ether")
        self.balanceInDollars.text = ""
    }
}
