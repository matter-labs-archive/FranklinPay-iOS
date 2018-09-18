//
//  TokenDropdownManager.swift
//  DiveLane
//
//  Created by NewUser on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

protocol TokenSelectionDelegate: class {
    func didSelectToken(token: ERC20TokenModel)
}
class TokenDropdownManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: TokenSelectionDelegate?
    
    let localStorage = LocalDatabase()
    
    var tokens = [ERC20TokenModel]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCellDropdown") as? TokenCellDropdown else { return UITableViewCell() }
        guard let wallet = localStorage.getWallet() else { return UITableViewCell() }
        cell.configure(tokens[indexPath.row], wallet: wallet)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectToken(token: tokens[indexPath.row])
    }
}
