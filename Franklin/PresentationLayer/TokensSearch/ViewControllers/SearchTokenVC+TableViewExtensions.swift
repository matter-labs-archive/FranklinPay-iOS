//
//  SearchTokenVC+TableViewExtension.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension SearchTokenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tokensList.isEmpty {
            return 1
        } else {
            return tokensList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tokensList.isEmpty {
            return UIScreen.main.bounds.height * Constants.TokenSearchCell.emptyCoef
        } else {
            return UIScreen.main.bounds.height * Constants.TokenSearchCell.heightCoef
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !tokensList.isEmpty {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTokenCell",
                                                           for: indexPath) as? SearchTokenCell else {
                                                            return UITableViewCell()
            }
            
            cell.configure(with: tokensList[indexPath.row], isAdded: tokensAreAdded[indexPath.row])
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell",
                                                           for: indexPath) as? AddressTableViewCell else {
                                                            return UITableViewCell()
            }
            cell.qr.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
            cell.paste.addTarget(self, action: #selector(textFromBuffer), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is AddressTableViewCell {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let token = tokensList[indexPath.row]
        let isAdded = tokensAreAdded[indexPath.row]
        guard let wallet = wallet else {
            return
        }
        do {
            if isAdded {
                try wallet.delete(token: token, network: CurrentNetwork.currentNetwork)
                if !tokensForDeleting.contains(token) {
                    tokensForDeleting.insert(token)
                }
                tokensAreAdded[indexPath.row] = false
                CurrentToken.currentToken = Ether()
            } else {
                try wallet.add(token: token, network: CurrentNetwork.currentNetwork)
                if !tokensForAdding.contains(token) {
                    tokensForAdding.insert(token)
                }
                tokensAreAdded[indexPath.row] = true
            }
            reloadTableData()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
