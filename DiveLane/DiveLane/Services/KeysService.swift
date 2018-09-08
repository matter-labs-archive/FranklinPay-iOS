//
//  KeysService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol IKeysService {
    func selectedWallet() -> KeyWalletModel?
    func selectedKey() -> HDKey?
    func keystoreManager() -> KeystoreManager
    func addNewWalletWithPrivateKey(withName: String?,
                                    key: String,
                                    password: String,
                                    completion: @escaping (KeyWalletModel?, Error?) -> Void)
    func createNewWallet(withName: String?,
                         password: String,
                         completion: @escaping (KeyWalletModel?, Error?) -> Void)
    func getWalletPrivateKey(password: String) -> String?
}
