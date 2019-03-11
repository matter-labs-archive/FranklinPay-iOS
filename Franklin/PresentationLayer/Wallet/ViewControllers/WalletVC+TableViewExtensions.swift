//
//  WalletTableView.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if CurrentNetwork.currentNetwork.isXDai() {
//            return nil
//        }
        guard let wallet = CurrentWallet.currentWallet else {return nil}
        let background: TableHeader = TableHeader(for: wallet)
        background.delegate = self
        return background
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if CurrentNetwork.currentNetwork.isXDai() {
//            return 0
//        }
        switch section {
        case WalletSections.card.rawValue:
            return 0
        case WalletSections.tokens.rawValue:
            return Constants.Headers.Heights.tokens
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Cards will be only on Mainnet, Rinkebi and xDai
        let unsupportedPlasmaNetworks = !CurrentNetwork.currentNetwork.isMainnet() && !CurrentNetwork.currentNetwork.isRinkebi() && !CurrentNetwork.currentNetwork.isXDai()
        
        switch indexPath.section {
        case WalletSections.card.rawValue:
            if unsupportedPlasmaNetworks {
                return 0
            }
            return UIScreen.main.bounds.height * Constants.CardCell.heightCoef
        case WalletSections.tokens.rawValue:
            return UIScreen.main.bounds.height * Constants.TokenCell.heightCoef
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return walletSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for token in tokensArray {
            if token.isCard {
                count += 1
            }
        }
        switch section {
        case WalletSections.card.rawValue:
            return count
        case WalletSections.tokens.rawValue:
            return tokensArray.count - count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tokensArray.isEmpty {return UITableViewCell()}
//        let card = tokensArray[0]
//        var tokens = tokensArray
        
        //tokens.removeFirst()
        
        var cards = [TableToken]()
        var tokens = [TableToken]()
        
        for token in tokensArray {
            if token.isCard {
                cards.append(token)
            } else {
                tokens.append(token)
            }
        }
        
        switch indexPath.section {
        case WalletSections.card.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell",
                                                           for: indexPath) as? CardCell else {
                                                            return UITableViewCell()
            }
            let tableToken = cards[indexPath.row]
            cell.configure(token: tableToken)
            cell.delegate = self
            return cell
        case WalletSections.tokens.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell",
                                                           for: indexPath) as? TokenCell else {
                                                            return UITableViewCell()
            }
            let tableToken = tokens[indexPath.row]
            cell.configure(token: tableToken)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
//            return
//        }
        let isCard = indexPath.section == WalletSections.card.rawValue
//        guard let cell = isCard ?
//            tableView.cellForRow(at: indexPath) as? CardCell :
//            tableView.cellForRow(at: indexPath) as? TokenCell else {
//                return
//        }
        
        var cards = [TableToken]()
        var tokens = [TableToken]()
        
        for token in tokensArray {
            if token.isCard {
                cards.append(token)
            } else {
                tokens.append(token)
            }
        }
        
        let tableToken = isCard ?
            cards[indexPath.row] :
            tokens[indexPath.row]
        
        showSend(token: tableToken.token)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteToken(in: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        var cards = [TableToken]()
        var tokens = [TableToken]()
        
        for token in tokensArray {
            if token.isCard {
                cards.append(token)
            } else {
                tokens.append(token)
            }
        }
        
        let isCard = indexPath.section == WalletSections.card.rawValue
        
        let tableToken = isCard ?
            cards[indexPath.row] :
            tokens[indexPath.row]
        
        if tableToken.token.isEther() || tableToken.token.isDai() || tableToken.token.isBuff() || tableToken.token.isXDai() || tableToken.token.isFranklin() {
            return false
        }
        
        return true
    }
}
