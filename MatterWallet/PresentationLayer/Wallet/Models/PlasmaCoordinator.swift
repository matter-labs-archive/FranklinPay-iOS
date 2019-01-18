//
//  UTXOsCoordinator.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import Web3swift
import BigInt

public class PlasmaCoordinator {
    
    private let tokensService = TokensService()
    private let walletsService = WalletsService()
    private let plasmaService = PlasmaService()
    
    public func getWalletsAndUTXOs() -> [ExpandableTableUTXOs] {
        var twoDimensionalUTXOsArray = [ExpandableTableUTXOs]()
        guard let wallets = try? WalletsService().getAllWallets() else {
            return []
        }
        let selectedNetwork = CurrentNetwork.currentNetwork
        let mainnet = selectedNetwork.id == Int64(Networks.Mainnet.chainID)
        let testnet = !mainnet
            && selectedNetwork.id == Int64(Networks.Rinkeby.chainID)
        if !testnet && !mainnet {
            return []
        }
        for wallet in wallets {
            guard let ethAddress = EthereumAddress(wallet.address),
                let utxos = try? plasmaService.getUTXOs(for: ethAddress,
                                                        onTestnet: testnet) else {
                continue
            }
            let expandableUTXOS = ExpandableTableUTXOs(isExpanded: true,
                                                       utxos: utxos.map {
                                                        TableUTXO(utxo: $0,
                                                                  inWallet: wallet,
                                                                  isSelected: false)
            })
            twoDimensionalUTXOsArray.append(expandableUTXOS)
        }
        return twoDimensionalUTXOsArray
    }
    
    public func formMergeUTXOsTransaction(for wallet: Wallet, utxos: [TableUTXO]) throws -> PlasmaTransaction {
        var inputs = [TransactionInput]()
        var mergedAmount: BigUInt = 0
        do {
            for utxo in utxos {
                let input = try? utxo.utxo.toTransactionInput()
                if let i = input {
                    inputs.append(i)
                    mergedAmount += i.amount
                }
            }
            guard let address = EthereumAddress(wallet.address) else {
                throw Errors.CommonErrors.unknown
            }
            let output = try TransactionOutput(outputNumberInTx: 0,
                                               receiverEthereumAddress: address,
                                               amount: mergedAmount)
            let outputs = [output]
            let transaction = try PlasmaTransaction(txType: .merge,
                                                    inputs: inputs,
                                                    outputs: outputs)
            return transaction
        } catch let error {
            throw error
        }
    }
    
}
