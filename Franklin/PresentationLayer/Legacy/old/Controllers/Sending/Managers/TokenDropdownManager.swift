////
////  TokenDropdownManager.swift
////  DiveLane
////
////  Created by NewUser on 18/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//protocol TokenSelectionDelegate: class {
//    func didSelectToken(token: ERC20TokenModel)
//    func didSelectUTXO(utxo: PlasmaUTXOs)
//}
//
//class TokenDropdownManager: NSObject, UITableViewDelegate, UITableViewDataSource {
//    weak var delegate: TokenSelectionDelegate?
//
//    let localStorage = WalletsService()
//
//    var tokens = [ERC20TokenModel]()
//    var utxos = [PlasmaUTXOs]()
//    var wallet: WalletModel?
//
//    var isPlasma: Bool = false
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isPlasma {
//            return utxos.count
//        } else {
//            return tokens.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCellDropdown") as?  TokenCellDropdown else {
//            return UITableViewCell()
//        }
//        guard let wallet = wallet else {
//            return UITableViewCell()
//        }
//        if isPlasma {
//            cell.configure(utxos[indexPath.row], wallet: wallet)
//        } else {
//            cell.configure(tokens[indexPath.row], wallet: wallet)
//        }
//        return cell
//
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if isPlasma {
//           delegate?.didSelectUTXO(utxo: utxos[indexPath.row])
//        } else {
//            delegate?.didSelectToken(token: tokens[indexPath.row])
//        }
//    }
//}
