//
//  URLs.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

/// Common URLs used in requests to Plasma
public class PlasmaURLs {

    public init() {}

    // Used to get list of UTXOs for specific address on Mainnet
    static let listUTXOsMainnet: URL = URL(string: "https://plasma.thematter.io/api/v1/listUTXOs")!
    // Used to get list of UTXOs for specific address on Rinkeby
    static let listUTXOsTestnet: URL = URL(string: "https://plasma-testnet.thematter.io/api/v1/listUTXOs")!
    // Used to send transaction in Plasma on Mainnet
    static let sendRawTXMainnet: URL = URL(string: "https://plasma.thematter.io/api/v1/sendRawTX")!
    // Used to send transaction in Plasma on Rinkeby
    static let sendRawTXTestnet: URL = URL(string: "https://plasma-testnet.thematter.io/api/v1/sendRawTX")!
    // Used to get block with set number on Mainnet
    static let blockStorageMainnet: String = "https://plasma.ams3.digitaloceanspaces.com/plasma/"
    // Used to get block with set number on Rinkeby
    static let blockStorageTestnet: String = "https://plasma-testnet.ams3.digitaloceanspaces.com/plasma/"
}
