//
//  WalletTransactions.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import BigInt

protocol IWalletTransactions {
    func getFranklinBalance() throws -> String
    func getERC20balance(for token: ERC20Token, web3instance: web3?) throws -> String
    func getETHbalance(web3instance: web3?) throws -> String
    func prepareSendEthTx(web3instance: web3?,
                          toAddress: String,
                          value: String,
                          gasLimit: TransactionOptions.GasLimitPolicy,
                          gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction
    func prepareSendERC20Tx(web3instance: web3?,
                            token: ERC20Token,
                            toAddress: String,
                            tokenAmount: String,
                            gasLimit: TransactionOptions.GasLimitPolicy,
                            gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction
    func prepareWriteContractTx(web3instance: web3?,
                                contractABI: String,
                                contractAddress: String,
                                contractMethod: String,
                                value: String,
                                gasLimit: TransactionOptions.GasLimitPolicy,
                                gasPrice: TransactionOptions.GasPricePolicy,
                                parameters: [AnyObject],
                                extraData: Data) throws -> WriteTransaction
    func prepareReadContractTx(web3instance: web3?,
                               contractABI: String,
                               contractAddress: String,
                               contractMethod: String,
                               gasLimit: TransactionOptions.GasLimitPolicy,
                               gasPrice: TransactionOptions.GasPricePolicy,
                               parameters: [AnyObject],
                               extraData: Data) throws -> ReadTransaction
    func sendTx(transaction: WriteTransaction,
                options: TransactionOptions?,
                password: String) throws -> TransactionSendingResult
    func callTx(transaction: ReadTransaction,
                options: TransactionOptions?) throws -> [String : Any]
}

extension Wallet: IWalletTransactions {
    
    public func getFranklinBalance() throws -> String {
        let id = try self.getID()
        try self.setID(String(id))
        print("plasma id : \(id.description)")
        
        let currentNetwork = CurrentNetwork.currentNetwork
        let balance = try self.getPlasmaBalance(network: currentNetwork)
        return balance
    }
    
    public func getETHbalance(web3instance: web3? = nil) throws -> String {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let walletAddress = EthereumAddress(self.address),
            let balanceResult = try? web3.eth.getBalance(address: walletAddress)
            else {
                throw Web3Error.walletError
        }
        guard let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3) else {
            throw Web3Error.dataError
        }
        return balanceString
    }
    
    public func getERC20balance(for token: ERC20Token, web3instance: web3? = nil) throws -> String {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        do {
            guard let walletAddress = EthereumAddress(self.address) else {
                throw Web3Error.walletError
            }
            let tx = try self.prepareReadContractTx(web3instance: web3,
                                                    contractABI: Web3.Utils.erc20ABI,
                                                    contractAddress: token.address,
                                                    contractMethod: "balanceOf",
                                                    gasLimit: .automatic,
                                                    gasPrice: .automatic,
                                                    parameters: [walletAddress] as [AnyObject],
                                                    extraData: Data())
            let tokenBalance = try self.callTx(transaction: tx)
            guard let balanceResult = tokenBalance["0"] as? BigUInt,
                let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3) else {
                    throw Web3Error.dataError
            }
            return balanceString
        } catch let error {
            throw error
        }
    }
    
    public func prepareSendEthTx(web3instance: web3? = nil,
                                 toAddress: String,
                                 value: String = "0.0",
                                 gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                 gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let ethAddress = EthereumAddress(toAddress),
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: ethAddress, abiVersion: 2) else {
                throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = self.defaultOptions()
        options.value = amount
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.write("fallback",
                                      parameters: [AnyObject](),
                                      extraData: Data(),
                                      transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareSendERC20Tx(web3instance: web3? = nil,
                                   token: ERC20Token,
                                   toAddress: String,
                                   tokenAmount: String = "0.0",
                                   gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                   gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let ethTokenAddress = EthereumAddress(token.address),
            let ethToAddress = EthereumAddress(toAddress),
            let contract = web3.contract(Web3.Utils.erc20ABI, at: ethTokenAddress, abiVersion: 2) else {
                throw Web3Error.dataError
        }
        
        let amount = Web3.Utils.parseToBigUInt(tokenAmount, units: .eth)
        var options = self.defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.write("transfer",
                                      parameters: [ethToAddress, amount] as [AnyObject],
                                      extraData: Data(),
                                      transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareWriteContractTx(web3instance: web3? = nil,
                                       contractABI: String,
                                       contractAddress: String,
                                       contractMethod: String,
                                       value: String = "0.0",
                                       gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                       gasPrice: TransactionOptions.GasPricePolicy = .automatic,
                                       parameters: [AnyObject] = [AnyObject](),
                                       extraData: Data = Data()) throws -> WriteTransaction {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let ethContractAddress = EthereumAddress(contractAddress),
            let contract = web3.contract(contractABI, at: ethContractAddress, abiVersion: 2) else {
                throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = self.defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        options.value = amount
        guard let tx = contract.write(contractMethod,
                                      parameters: parameters,
                                      extraData: extraData,
                                      transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareReadContractTx(web3instance: web3? = nil,
                                      contractABI: String,
                                      contractAddress: String,
                                      contractMethod: String,
                                      gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                      gasPrice: TransactionOptions.GasPricePolicy = .automatic,
                                      parameters: [AnyObject] = [AnyObject](),
                                      extraData: Data = Data()) throws -> ReadTransaction {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let ethContractAddress = EthereumAddress(contractAddress),
            let contract = web3.contract(contractABI, at: ethContractAddress, abiVersion: 2) else {
                throw Web3Error.dataError
        }
        var options = self.defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.read(contractMethod,
                                     parameters: parameters,
                                     extraData: extraData,
                                     transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func sendTx(transaction: WriteTransaction,
                       options: TransactionOptions? = nil,
                       password: String) throws -> TransactionSendingResult {
        do {
            let txOptions = options ?? transaction.transactionOptions
//            var txOptions = options ?? transaction.transactionOptions
//            txOptions.gasPrice = .manual(BigUInt(1100000000))
//            txOptions.gasLimit = .manual(BigUInt(120000))
            let result = try transaction.send(password: password, transactionOptions: txOptions)
            return result
        } catch let error {
            throw error
        }
    }
    
    public func callTx(transaction: ReadTransaction,
                       options: TransactionOptions? = nil) throws -> [String : Any] {
        do {
            let txOptions = options ?? transaction.transactionOptions
            let result = try transaction.call(transactionOptions: txOptions)
            return result
        } catch let error {
            throw error
        }
    }
    
    internal func defaultOptions() -> TransactionOptions {
        var options = TransactionOptions.defaultOptions
        let address = EthereumAddress(self.address)
        options.from = address
        return options
    }
}
