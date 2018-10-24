//
//  URLs.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

final class URLs {
    static let listUTXOsMainnet: URL = URL(string: "https://plasma.thematter.io/api/v1/listUTXOs")!
    static let listUTXOsTestnet: URL = URL(string: "https://plasma-testnet.thematter.io/api/v1/listUTXOs")!
    static let sendRawTXMainnet: URL = URL(string: "https://plasma.thematter.io/api/v1/sendRawTX")!
    static let sendRawTXTestnet: URL = URL(string: "https://plasma-testnet.thematter.io/api/v1/sendRawTX")!
}
