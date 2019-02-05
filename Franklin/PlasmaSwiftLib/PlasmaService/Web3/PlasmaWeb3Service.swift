//
//  TransactionsService.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 08.11.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import BigInt

/// Methods for Plasma Contract interaction
public final class PlasmaWeb3Service {
    
    private let web3: web3
    private let fromAddress: EthereumAddress
    private let plasmaAddress: EthereumAddress
    
    /// Creates Web3Service object
    ///
    /// - Parameters:
    ///   - web3: A web3 instance bound to provider
    ///   - keystoreManager: manager of your private keys
    ///   - fromAddress: specific Ethereum Address structure
    init(web3: web3, keystoreManager: KeystoreManager, fromAddress: EthereumAddress) {
        self.web3 = web3
        web3.addKeystoreManager(keystoreManager)
        self.fromAddress = fromAddress
        let address = EthereumAddress(PlasmaContract.plasmaAddress)
        precondition(address != nil)
        self.plasmaAddress = address!
    }
    
    private lazy var defaultOptions: TransactionOptions = {
        var options = TransactionOptions.defaultOptions
        options.from = fromAddress
        options.to = plasmaAddress
        return options
    }()
    
    private lazy var plasmaContract: web3.web3contract = {
        let address = EthereumAddress(PlasmaContract.plasmaAddress)
        precondition(address != nil)
        let contract = self.web3.contract(PlasmaContract.plasmaABI, at: address!, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    /// Prepares transaction that writes to some method of Plasma Contract in Ethereum Blockchain. It is broadcasted to the network, processed by miners, and if valid, is published on the blockchain, consuming Ether.
    ///
    /// - Parameters:
    ///   - method: method of Plasma Contract
    ///   - value: Ether amount that is sending to Plasma Contract
    ///   - parameters: an array corresponding to the list of parameters of the Plasma Contract method. Can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress
    ///   - extraData: additional data specific for used Plasma Contract method - it is appended to encoded parameters
    /// - Returns: Ethereum transaction object
    /// - Throws: `Web3Error.transactionSerializationError` if there is some errors in serialization
    public func preparePlasmaContractWriteTx(method: PlasmaContractMethod = .deposit,
                                             value: String = "0.0",
                                             parameters: [AnyObject] = [AnyObject](),
                                             extraData: Data = Data()) throws -> WriteTransaction {
        
        let contract = plasmaContract
        var options = defaultOptions
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        options.value = amount
        
        guard let transaction = contract.write(method.rawValue,
                                                parameters: parameters,
                                                extraData: extraData,
                                                transactionOptions: options) else {
                                            throw Web3Error.transactionSerializationError
        }
        return transaction
    }
    
    /// Prepares transaction that writes to some method of Plasma Contract in Ethereum Blockchain. It is broadcasted to the network, processed by miners, and if valid, is published on the blockchain, consuming Ether.
    ///
    /// - Parameters:
    ///   - method: method of Plasma Contract
    ///   - value: Wei amount that is sending to Plasma Contract
    ///   - parameters: an array corresponding to the list of parameters of the Plasma Contract method. Can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress
    ///   - extraData: additional data specific for used Plasma Contract method - it is appended to encoded parameters
    /// - Returns: Ethereum transaction object
    /// - Throws: `Web3Error.transactionSerializationError` if there is some errors in serialization
    public func preparePlasmaContractWriteTx(method: PlasmaContractMethod = .deposit,
                                             value: BigUInt = 0,
                                             parameters: [AnyObject] = [AnyObject](),
                                             extraData: Data = Data()) throws -> WriteTransaction {
        
        let contract = plasmaContract
        var options = defaultOptions
        options.value = value
        
        guard let transaction = contract.write(method.rawValue,
                                               parameters: parameters,
                                               extraData: extraData,
                                               transactionOptions: options) else {
                                                throw Web3Error.transactionSerializationError
        }
        return transaction
    }
    
    /// Prepares transaction that calls to some method of Plasma Contract in Ethereum Blockchain. A call is a local invocation of a contract method that does not broadcast or publish anything on the blockchain and it will not consume any Ether.
    ///
    /// - Parameters:
    ///   - method: method of Plasma Contract
    ///   - value: Ether amount that is sending to Plasma Contract
    ///   - parameters: an array corresponding to the list of parameters of the Plasma Contract method. Can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress
    ///   - extraData: additional data specific for used Plasma Contract method - it is appended to encoded parameters
    /// - Returns: Ethereum transaction object
    /// - Throws: `Web3Error.transactionSerializationError` if there is some errors in serialization
    public func preparePlasmaContractReadTx(method: PlasmaContractMethod = .withdrawCollateral,
                                            value: String = "0.0",
                                            parameters: [AnyObject] = [AnyObject](),
                                            extraData: Data = Data()) throws -> ReadTransaction {
        
        let contract = plasmaContract
        var options = defaultOptions
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        options.value = amount
        
        guard let transaction = contract.read(method.rawValue,
                                              parameters: parameters,
                                              extraData: extraData,
                                              transactionOptions: options) else {
                                                    throw Web3Error.transactionSerializationError
        }
        return transaction
    }
    
    /// Prepares transaction that calls to some method of Plasma Contract in Ethereum Blockchain. A call is a local invocation of a contract method that does not broadcast or publish anything on the blockchain and it will not consume any Ether.
    ///
    /// - Parameters:
    ///   - method: method of Plasma Contract
    ///   - value: Wei amount that is sending to Plasma Contract
    ///   - parameters: an array corresponding to the list of parameters of the Plasma Contract method. Can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress
    ///   - extraData: additional data specific for used Plasma Contract method - it is appended to encoded parameters
    /// - Returns: Ethereum transaction object
    /// - Throws: `Web3Error.transactionSerializationError` if there is some errors in serialization
    public func preparePlasmaContractReadTx(method: PlasmaContractMethod = .withdrawCollateral,
                                            value: BigUInt = 0,
                                            parameters: [AnyObject] = [AnyObject](),
                                            extraData: Data = Data()) throws -> ReadTransaction {
        
        let contract = plasmaContract
        var options = defaultOptions
        options.value = value
        
        guard let transaction = contract.read(method.rawValue,
                                              parameters: parameters,
                                              extraData: extraData,
                                              transactionOptions: options) else {
                                                throw Web3Error.transactionSerializationError
        }
        return transaction
    }
    
    /// Sends transaction in Ethereum blockchain to Plasma Contract. It is broadcasted to the network, processed by miners, and if valid, is published on the blockchain, consuming Ether.
    ///
    /// - Parameters:
    ///   - transaction: `write` type transaction
    ///   - options: additional options for sending that transaction: to, from adresses, gas limit, gas price, value and some others. It will override the options in pre-formed transaction.
    ///   - password: password requered due to using Matter web3swift. You place it in keystore.
    /// - Returns: Transaction Sending Result: the Ethereum Transaction structure and the hash of that transaction to find it in some Ethereum blockchain scanner
    /// - Throws: Web3Error.processingError if there is some errors in sending transaction
    public func sendPlasmaContractTx(transaction: WriteTransaction,
                                     options: TransactionOptions? = nil,
                                     password: String? = nil) throws -> TransactionSendingResult {
        let options = options ?? transaction.transactionOptions
        let result = try transaction.send(password: password ?? "web3swift", transactionOptions: options)
        return result
    }
    
    /// Calls some method of Plasma Contract. A call is a local invocation of a contract method that does not broadcast or publish anything on the blockchain and it will not consume any Ether.
    ///
    /// - Parameters:
    ///   - transaction: `call` type transaction
    ///   - options: additional options for sending that transaction: to, from adresses, gas limit, gas price, value and some others. It will override the options in pre-formed transaction.
    /// - Returns: Dictionary with answer from contract method
    /// - Throws: Web3Error.processingError if there is some errors in sending transaction
    public func callPlasmaContractTx(transaction: ReadTransaction,
                                     options: TransactionOptions? = nil) throws -> [String: Any] {
        let options = options ?? transaction.transactionOptions
        guard let result = try? transaction.call(transactionOptions: options) else {
                throw Web3Error.processingError(desc: "Can't send transaction")
        }
        return result
    }
}
