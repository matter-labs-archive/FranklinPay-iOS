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
    
    var localDatabase: ILocalDatabase?
    var keysService: IKeysService?
    var wallets: [KeyWalletModel]?
    var twoDimensionalTokensArray: [ExpandableTableTokens] = []
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.selectedItem?.title = nil
        let nib = UINib.init(nibName: "TokenCell", bundle: nil)
        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        self.walletTableView.tableFooterView = UIView()
        self.walletTableView.addSubview(self.refreshControl)
        self.walletTableView.register(nib, forCellReuseIdentifier: "TokenCell")
        
        initDatabase()
        
        self.navigationItem.setRightBarButton(addTokenBarItem(), animated: false)
    }
    
    func initDatabase() {
        localDatabase = LocalDatabase()
        wallets = localDatabase?.getAllWallets()
        keysService = KeysService()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Wallet"
        self.tabBarController?.tabBar.selectedItem?.title = nil
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    func selectToken(cell: UITableViewCell) {
        
        guard let indexPathTapped = walletTableView.indexPath(for: cell) else { return }
        
        let token = twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]
        print(token)
        
        let isSelected = token.isSelected
        CurrentToken.currentToken = token.token
        twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row].isSelected = !isSelected
        
        cell.accessoryView?.tintColor = isSelected ? UIColor.lightGray : .red
    }
    
    func updateData() {
        twoDimensionalTokensArray.removeAll()
        getTokensList { [weak self] in
            self?.walletTableView.reloadData()
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        updateData()
        refreshControl.endRefreshing()
    }
    
    func addTokenBarItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        return addButton
    }
    
    @objc func addToken() {
        let searchTokenController = SearchTokenViewController()
        self.navigationController?.pushViewController(searchTokenController, animated: true)
    }
    
    
    func getTokensList(completion: @escaping ()->()) {
        guard let wallets = wallets else { return }
        
        let networkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
        
        for wallet in wallets {
            let tokensForWallet = localDatabase?.getAllTokens(for: wallet, forNetwork: networkID)
            if let tokens = tokensForWallet {
                let expandableTokens = ExpandableTableTokens(isExpanded: true,
                                                             tokens: tokens.map{ TableToken(token: $0, inWallet: wallet, isSelected: false)})
                twoDimensionalTokensArray.append(expandableTokens)
            }
        }
    }
    
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)

        button.tag = section

        return button
    }
    
    @objc func handleExpandClose(button: UIButton) {
        
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        for row in twoDimensionalTokensArray[section].tokens.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = twoDimensionalTokensArray[section].isExpanded
        twoDimensionalTokensArray[section].isExpanded = !isExpanded
        
        button.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            walletTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            walletTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalTokensArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimensionalTokensArray[section].isExpanded {
            return 0
        }
        
        return twoDimensionalTokensArray[section].tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell", for: indexPath) as! TokenCell
        cell.link = self
        let token = twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row]
        cell.configure(token: token.token, forWallet: token.inWallet)
        
        cell.accessoryView?.tintColor = token.isSelected ? UIColor.red : .lightGray
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {return}
//        let selectedCell = tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
//
//        CurrentToken.currentToken = listOfTokens[indexPath.row]
//
//        let tokenViewController = TokenViewController(
//            walletAddress: currentWallet ?? "",
//            walletName: selectedCell?.walletName.text ?? "",
//            tokenBalance: selectedCell?.balance.text ?? "0")
//        self.navigationController?.pushViewController(tokenViewController, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
