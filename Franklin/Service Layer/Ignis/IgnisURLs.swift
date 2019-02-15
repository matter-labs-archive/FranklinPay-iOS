//
//  IgnisURLs.swift
//  Franklin
//
//  Created by Anton on 12/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class IgnisURLs {
    
    public init() {}
    static let sendRawTXMainnet: URL = URL(string: "https://api.plasma-winter.io/send")!
    static let sendRawTXTestnet: URL = URL(string: "https://api.plasma-winter.io/send")!
    static let getDataMainnet: String = "https://api.plasma-winter.io/account/"
    static let getDataTestnet: String = "https://api.plasma-winter.io/account/"
    static let getTXsMainnet: URL = URL(string: "https://api.plasma-winter.io/txs")!
    static let getTXsTestnet: URL = URL(string: "https://api.plasma-winter.io/txs")!
}
