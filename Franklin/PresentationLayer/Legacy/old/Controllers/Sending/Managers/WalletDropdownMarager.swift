////
////  WalletDropdownMarager.swift
////  DiveLane
////
////  Created by NewUser on 18/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//protocol WalletSelectionDelegate: class {
//    func didSelectWallet(wallet: WalletModel)
//}
//
//class WalletDropdownManager: NSObject, UITableViewDelegate, UITableViewDataSource {
//    weak var delegate: WalletSelectionDelegate?
//
//    var wallets = [WalletModel]()
//
//    var isPlasma: Bool = false
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return wallets.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCellDropdown") as? WalletCellDropdown else {
//            return UITableViewCell()
//        }
//        cell.configure(wallets[indexPath.row])
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        delegate?.didSelectWallet(wallet: wallets[indexPath.row])
//    }
//}
