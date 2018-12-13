//
//  TokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import PlasmaSwiftLib
import EthereumAddress

class TokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var tokenShortName: UILabel!
    @IBOutlet weak var tokenIcon: UIImageView!
    @IBOutlet weak var tokenAddress: UILabel!
    @IBOutlet weak var balanceInDollars: UILabel!

    var link: WalletViewController?
    var isPlasma: Bool = false

    let keysService = WalletsService()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureForEtherBlockchain(token: ERC20TokenModel?, forWallet: WalletModel, isSelected: Bool) {
        guard let token = token else {return}
        isPlasma = false
        self.tokenShortName.text = token.symbol.uppercased()
        updateBalanceAndAddress(for: token, forWallet: forWallet)
        changeSelectButton(isSelected: isSelected)
    }

    func configureForPlasmaBlockchain(utxo: PlasmaUTXOs, token: ERC20TokenModel = ERC20TokenModel(isEther: true), forWallet: WalletModel) {
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

    func updateBalanceAndAddress(for token: ERC20TokenModel, forWallet: WalletModel) {
        do {
            if token == ERC20TokenModel(isEther: true) {
                self.tokenAddress.text = "Wallet address: \(forWallet.address.hideExtraSymbolsInAddress())"
                let balance = try Web3Service().getETHbalance(for: forWallet)
                DispatchQueue.main.async { [weak self] in
                    self?.balance.text = balance
                    self?.updateBalanceInDollars(for: token, withBalance: balance)
                }
            } else {
                self.tokenAddress.text = "Token address: \(token.address.hideExtraSymbolsInAddress())"
                let balance = try Web3Service().getERC20balance(for: forWallet, token: token)
                DispatchQueue.main.async { [weak self] in
                    self?.balance.text = balance
                    self?.updateBalanceInDollars(for: token, withBalance: balance)
                }
            }
        } catch {
            return
        }
    }

    func updateBalanceInDollars(for token: ERC20TokenModel, withBalance: String?) {
        do {
            let conversion = try TokensService().updateConversion(for: token)
            DispatchQueue.main.async { [weak self] in
                let conv: Double = conversion
                let resultInDouble: Double = Double(withBalance ?? "0") ?? 0
                let convertedAmount = Double(round(100*(conv * resultInDouble))/100)
                let stringAmount =  String(convertedAmount)
                self?.balanceInDollars.text = stringAmount + "$"
            }
        } catch {
            return
        }
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
