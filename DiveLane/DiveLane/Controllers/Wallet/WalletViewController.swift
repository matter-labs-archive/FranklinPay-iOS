//
//  WalletViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController {
    
    @IBOutlet weak var walletTableView: UITableView!
    
    var listOfTokens = [ERC20TokenModel]()
    var currentWallet: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Wallet"
        
        self.getTokensList()
        self.currentWallet = KeysService().selectedWallet()?.address
        
        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        walletTableView.tableFooterView = UIView()
        
        let nib = UINib.init(nibName: "TokenCell", bundle: nil)
        self.walletTableView.register(nib, forCellReuseIdentifier: "TokenCell")
        
    }
    
    func getTokensList() {
        listOfTokens.append(ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth"))
        listOfTokens.append(ERC20TokenModel(name: "BKX", address: "0x45245bc59219eeaaf6cd3f382e078a461ff9de7b", decimals: "18", symbol: "BKX"))
        walletTableView.reloadData()
    }
    
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case WalletTableViewSections.tokensList.rawValue:
            return listOfTokens.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case WalletTableViewSections.tokensList.rawValue:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == WalletTableViewSections.tokensList.rawValue {
            return "Tokens list"
        } else {
            return "..."
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case WalletTableViewSections.tokensList.rawValue :
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell", for: indexPath) as! TokenCell
            cell.configure(token: listOfTokens[indexPath.row], forWallet: currentWallet ?? "")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySectionCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {return}
        let selectedCell = tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
        
        CurrentToken.currentToken = listOfTokens[indexPath.row]
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
