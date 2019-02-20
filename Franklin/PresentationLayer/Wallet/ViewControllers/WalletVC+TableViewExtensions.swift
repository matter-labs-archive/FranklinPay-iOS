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
        if CurrentNetwork().isXDai() {
            return nil
        }
        guard let wallet = CurrentWallet.currentWallet else {return nil}
        let background: TableHeader = TableHeader(for: wallet)
        background.delegate = self
        return background
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if CurrentNetwork().isXDai() {
            return 0
        }
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
        switch indexPath.section {
        case WalletSections.card.rawValue:
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
        switch section {
        case WalletSections.card.rawValue:
            return 1
        case WalletSections.tokens.rawValue:
            return tokensArray.count - 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tokensArray.isEmpty {return UITableViewCell()}
        let card = tokensArray[0]
        var tokens = tokensArray
        tokens.removeFirst()
        switch indexPath.section {
        case WalletSections.card.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell",
                                                           for: indexPath) as? CardCell else {
                                                            return UITableViewCell()
            }
            let tableToken = card
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
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
            return
        }
        let isCard = indexPath.section == WalletSections.card.rawValue
        let cell = isCard ?
            tableView.cellForRow(at: indexPathForSelectedRow) as? CardCell :
            tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
        guard let selectedCell = cell else {
            return
        }
        guard let indexPathTapped = walletTableView.indexPath(for: selectedCell) else {
            return
        }
        let tableToken = isCard ?
            tokensArray[0] :
            tokensArray[indexPathTapped.row+1]
        
        showSend(token: tableToken.token)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteToken(in: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if CurrentNetwork().isXDai() {
            return false
        }
        if indexPath.section == WalletSections.card.rawValue {
            return false
        }
        let cell = tableView.cellForRow(at: indexPath) as? TokenCell
        guard let selectedCell = cell else {
            return false
        }
        guard let indexPathTapped = walletTableView.indexPath(for: selectedCell) else {
            return false
        }
        let token = tokensArray[indexPathTapped.row].token
        if token.isEther() || token.isDai() {
            return false
        }
        return true
    }
}
