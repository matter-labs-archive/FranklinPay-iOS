//
//  SendMoneyVC+Actions.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt

extension SendMoneyController {
    func sendToken(_ token: ERC20Token) {
        DispatchQueue.global().async { [unowned self] in
            guard let wallet = CurrentWallet.currentWallet else { return }
            guard let amount = self.topTextField.text else { return }
            guard let address = self.chosenContact?.address else { return }
            do {
                let changeWeb3 = CurrentNetwork.currentNetwork.isXDai()
                    ? try MainnetNetwork().getWeb()
                    : nil
                let tx = try wallet.prepareSendERC20Tx(web3instance: changeWeb3,
                                                       token: token,
                                                       toAddress: address,
                                                       tokenAmount: amount,
                                                       gasLimit: .manual(BigUInt(120000)),
                                                       gasPrice: .manual(BigUInt(15000000000)))
                let password = try wallet.getPassword()
                _ = try wallet.sendTx(transaction: tx, options: nil, password: password)
                self.showReady(animated: true)
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: "Error occurred: \(error.localizedDescription)", completion: { [unowned self] in
                    self.showStart(animated: true)
                })
            }
        }
    }
    
    func sendTokenXDai(_ token: ERC20Token) {
        DispatchQueue.global().async { [unowned self] in
            guard let wallet = CurrentWallet.currentWallet else { return }
            guard let amount = self.topTextField.text else { return }
            guard let address = self.chosenContact?.address else { return }
            do {
                let tx = try wallet.prepareSendERC20XDaiTx(token: token,
                                                           toAddress: address,
                                                           tokenAmount: amount,
                                                           gasLimit: .manual(BigUInt(120000)),
                                                           gasPrice: .manual(BigUInt(1100000000)))
                let password = try wallet.getPassword()
                let txResult = try wallet.sendTx(transaction: tx, options: nil, password: password)
                try self.saveTransaction(wallet: wallet, value: amount, txResult: txResult, token: token)
                self.showReady(animated: true)
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: "Error occurred: \(error.localizedDescription)", completion: { [unowned self] in
                    self.showStart(animated: true)
                })
            }
        }
    }
    
    func sendEther() {
        DispatchQueue.global().async { [unowned self] in
            guard let wallet = CurrentWallet.currentWallet else { return }
            guard let amount = self.topTextField.text else { return }
            guard let address = self.chosenContact?.address else { return }
            do {
                let changeWeb3 = CurrentNetwork.currentNetwork.isXDai()
                    ? try MainnetNetwork().getWeb()
                    : nil
                let tx = try wallet.prepareSendEthTx(web3instance: changeWeb3,
                                                     toAddress: address,
                                                     value: amount,
                                                     gasLimit: .manual(BigUInt(120000)),
                                                     gasPrice: .manual(BigUInt(15000000000)))
                let password = try wallet.getPassword()
                let txResult = try wallet.sendTx(transaction: tx, options: nil, password: password)
                try self.saveTransaction(wallet: wallet, value: amount, txResult: txResult, token: nil)
                self.showReady(animated: true)
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: "Error occurred: \(error.localizedDescription)", completion: { [unowned self] in
                    self.showStart(animated: true)
                })
            }
        }
    }
    
    func sendXDai() {
        DispatchQueue.global().async { [unowned self] in
            guard let wallet = CurrentWallet.currentWallet else { return }
            guard let amount = self.topTextField.text else { return }
            guard let address = self.chosenContact?.address else { return }
            do {
                let password = try wallet.getPassword()
                let tx = try wallet.prepareSendXDaiTx(toAddress: address,
                                                      value: amount,
                                                      gasLimit: .manual(BigUInt(120000)),
                                                      gasPrice: .manual(BigUInt(1100000000)))
                let txResult = try wallet.sendTx(transaction: tx, options: nil, password: password)
                try self.saveTransaction(wallet: wallet, value: amount, txResult: txResult, token: nil)
                self.showReady(animated: true)
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: "Error occurred: \(error.localizedDescription)", completion: { [unowned self] in
                    self.showStart(animated: true)
                })
            }
        }
    }
    
    internal func saveTransaction(wallet: Wallet, value: String, txResult: TransactionSendingResult, token: ERC20Token?) throws {
        let transaction = ETHTransaction(transactionHash: txResult.hash,
                                         from: txResult.transaction.sender!.address,
                                         to: txResult.transaction.to.address,
                                         amount: value,
                                         date: Date.init(),
                                         data: txResult.transaction.data,
                                         token: token,
                                         networkId: CurrentNetwork.currentNetwork.id,
                                         isPending: true)
        try wallet.save(transactions: [transaction])
    }
}
