//
//  PlasmaContractOperations.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 16.11.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import BigInt

/// Convinient methods for Plasma Contract interaction
extension PlasmaWeb3Service {
    
    /// Method that completes withdraw funds from plasma, calling withdrawCollateral and startExit methods.
    ///
    /// - Parameters:
    ///   - transaction: signed transaction that needs to be withdrawned;
    ///   - proof: proof shows that the transaction is valid. Merkle proof is established by hashing a hash's corresponding hash together and climbing up the tree until you obtain the root hash which is or can be publicly known;
    ///   - blockNumber: the number of Block from which transaction will be withdrawn;
    ///   - outputNumber: output number of transaction;
    ///   - password: password requered due to using Matter web3swift. You place it in keystore.
    /// - Returns: Transaction Sending Result: the Ethereum Transaction structure and the hash of that transaction to find it in some Ethereum blockchain scanner
    /// - Throws:
    ///     - `StructureErrors.wrongData` if withdraw collateral is wrong.
    ///     - `NetErrors.cantCreateRequest` if sending transaction caused error
    public func startExitPlasma(transaction: SignedTransaction,
                                proof: Data,
                                blockNumber: BigUInt,
                                outputNumber: BigUInt,
                                password: String? = nil) throws -> TransactionSendingResult {
        print(transaction.data.toHexString())
        print(proof.toHexString())
        print(blockNumber)
        print(outputNumber)
        do {
            let txWithdraw = try preparePlasmaContractReadTx(method: .withdrawCollateral,
                                                             value: 0,
                                                             parameters: [AnyObject](),
                                                             extraData: Data())
            let withdrawCollateral = try callPlasmaContractTx(transaction: txWithdraw)
            guard let withdrawCollateralBigUInt = withdrawCollateral.first?.value as? BigUInt else {throw PlasmaErrors.StructureErrors.wrongData}
            print("collateral: \(withdrawCollateralBigUInt)")
            let txData = try transaction.serialize()
            let bN = UInt32(blockNumber)
            let oN = UInt8(outputNumber)
            let txHex = [UInt8](txData)
            let proofHex = [UInt8](proof)
            let parameters = [bN,
                              oN,
                              txHex,
                              proofHex] as [AnyObject]
            let txStartExit = try preparePlasmaContractWriteTx(method: .startExit,
                                                               value: withdrawCollateralBigUInt,
                                                               parameters: parameters,
                                                               extraData: Data())
            let startExitOptions = txStartExit.transactionOptions
//            let gas = try txStartExit.estimateGas(transactionOptions: startExitOptions)
//            startExitOptions.gasPrice = .manual(gas)
            let result = try sendPlasmaContractTx(transaction: txStartExit,
                                                  options: startExitOptions,
                                                  password: password)
            return result
        } catch {
            throw PlasmaErrors.NetErrors.cantCreateRequest
        }
    }
    
    /// Completed method to withdraw funds from plasma UTXO.
    ///
    /// - Parameters:
    ///   - utxo: the Plasma UTXO structure
    ///   - onTestnet: Bool flag for possible endpoints:
    ///    1. True for Rinkeby testnet;
    ///    2. False for Mainnet.
    ///   - password: password requered due to using Matter web3swift. You place it in keystore.
    /// - Returns: Transaction Sending Result: the Ethereum Transaction structure and the hash of that transaction to find it in some Ethereum blockchain scanner
    /// - Throws:
    ///    - `StructureErrors.wrongData` if there is some errors in Block parsing, verifying or in contract Plasma calls
    public func withdrawUTXO(utxo: PlasmaUTXOs,
                             onTestnet: Bool,
                             password: String? = nil) throws -> TransactionSendingResult {
        let block = try PlasmaService().getBlock(onTestnet: true, number: utxo.blockNumber)
        do {
            let parsedBlock = try Block(data: block)
            let proofData = try parsedBlock.getProofForTransactionByNumber(txNumber: utxo.transactionNumber)
            guard let merkleTree = parsedBlock.merkleTree else {throw PlasmaErrors.StructureErrors.wrongData}
            guard let merkleRoot = merkleTree.merkleRoot else {throw PlasmaErrors.StructureErrors.wrongData}
            guard parsedBlock.blockHeader.merkleRootOfTheTxTree == merkleRoot else {throw PlasmaErrors.StructureErrors.wrongData}
            let included = PaddabbleTree.verifyBinaryProof(content: TreeContent(proofData.tx.data),
                                                           proof: proofData.proof,
                                                           expectedRoot: merkleRoot)
            guard included == true else {throw PlasmaErrors.StructureErrors.wrongData}
            
            let result = try self.startExitPlasma(transaction: proofData.tx,
                                                  proof: proofData.proof,
                                                  blockNumber: utxo.blockNumber,
                                                  outputNumber: utxo.outputNumber, password: password)
            return result
        } catch {
            throw PlasmaErrors.StructureErrors.wrongData
        }
    }
}
