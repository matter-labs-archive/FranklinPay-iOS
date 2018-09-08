//
//  LocalDatabase.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import CoreData
import BigInt

protocol ILocalDatabase {
    func getWallet() -> KeyWalletModel?
    func saveWallet(wallet: KeyWalletModel?, completion: @escaping (Error?)-> Void)
    func deleteWallet(completion: @escaping (Error?)-> Void)
}
