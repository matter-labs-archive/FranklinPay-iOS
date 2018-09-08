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
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    var listOfTokens = [ERC20TokenModel]()
    var currentWallet: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Wallet"
        self.tabBarController?.tabBar.selectedItem?.title = nil
        
        self.getTokensList()
        self.currentWallet = KeysService().selectedWallet()?.address
        
        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        walletTableView.tableFooterView = UIView()
        
        self.walletTableView.addSubview(self.refreshControl)
        
        let nib = UINib.init(nibName: "TokenCell", bundle: nil)
        self.walletTableView.register(nib, forCellReuseIdentifier: "TokenCell")
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.walletTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getTokensList() {
        listOfTokens.append(ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth"))
        listOfTokens.append(ERC20TokenModel(name: "BNB", address: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52", decimals: "18", symbol: "BNB"))
        listOfTokens.append(ERC20TokenModel(name: "SNT", address: "0x744d70fdbe2ba4cf95131626614a1763df805b9e", decimals: "18", symbol: "SNT"))
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
        
        let tokenViewController = TokenViewController(
            walletAddress: currentWallet ?? "",
            walletName: selectedCell?.walletName.text ?? "",
            tokenBalance: selectedCell?.balance.text ?? "0")
        self.navigationController?.pushViewController(tokenViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
