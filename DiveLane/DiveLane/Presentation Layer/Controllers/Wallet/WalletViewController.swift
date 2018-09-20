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
        //self.navigationItem.setRightBarButton(addTokenBarItem(), animated: false)
    }
    
    func initDatabase(complection: @escaping ()->()) {
        localDatabase = LocalDatabase()
        wallets = localDatabase?.getAllWallets()
        keysService = KeysService()
        complection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Wallets"
        self.tabBarController?.tabBar.selectedItem?.title = nil
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initDatabase { [weak self] in
            self?.updateData()
        }
    }
    
    func unselectAll() {
        var indexPath = IndexPath(row: 0, section: 0)
        for wallet in twoDimensionalTokensArray {
            for _ in wallet.tokens {
                self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].isSelected = false
                walletTableView.cellForRow(at: indexPath)?.accessoryView?.tintColor = .gray
                indexPath.row += 1
            }
            indexPath.section += 1
            indexPath.row = 0
        }
    }
    
    func selectToken(cell: UITableViewCell) {
        
        unselectAll()
        
        guard let indexPathTapped = walletTableView.indexPath(for: cell) else { return }
        
        let token = twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]
        print(token)
        
        CurrentToken.currentToken = token.token
        
        localDatabase?.selectWallet(wallet: token.inWallet, completion: { [weak self] in
            self?.twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row].isSelected = true
            cell.accessoryView?.tintColor = .red
        })
    }
    
    func updateData() {
        twoDimensionalTokensArray.removeAll()
        getTokensList { [weak self] in
            self?.walletTableView.reloadData()
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        initDatabase { [weak self] in
            self?.updateData()
            refreshControl.endRefreshing()
        }
    }
    
//    func addTokenBarItem() -> UIBarButtonItem {
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
//        return addButton
//    }
    
    @objc func addToken() {
        let searchTokenController = SearchTokenViewController()
        self.navigationController?.pushViewController(searchTokenController, animated: true)
    }
    
    
    func getTokensList(completion: @escaping ()->()) {
        guard let wallets = wallets else { return }
        
        let networkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
        
        for wallet in wallets {
            let tokensForWallet = localDatabase?.getAllTokens(for: wallet, forNetwork: networkID)
            let isSelectedWallet = wallet == keysService?.selectedWallet() ? true : false
            if let tokens = tokensForWallet {
                
                let expandableTokens = ExpandableTableTokens(isExpanded: true,
                                                             tokens: tokens.map{
                                                                TableToken(token: $0,
                                                                           inWallet: wallet,
                                                                           isSelected: ($0 == CurrentToken.currentToken) && isSelectedWallet )})
                twoDimensionalTokensArray.append(expandableTokens)
                completion()
            }
        }
    }
    
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        
        let walletButton = UIButton(frame: CGRect(x: 0, y: 0, width: (self.view.bounds.width*3/4), height: 30))
        walletButton.setTitle(twoDimensionalTokensArray[section].tokens.first?.inWallet.name, for: .normal)
        walletButton.setTitleColor(.white, for: .normal)
        walletButton.backgroundColor = .lightGray
        walletButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        walletButton.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        walletButton.tag = section
        
        backgroundView.addSubview(walletButton)
        
        let addButton = UIButton(frame: CGRect(x: (self.view.bounds.width*3/4), y: 0, width: (self.view.bounds.width*1/4), height: 30))
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .green
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        addButton.addTarget(self, action: #selector(handleAddToken), for: .touchUpInside)
        addButton.tag = section
        
        backgroundView.addSubview(addButton)
        
//        let leftWalletButtonConstraint = NSLayoutConstraint(item: walletButton,
//                                                            attribute: .left,
//                                                            relatedBy: .equal,
//                                                            toItem: backgroundView,
//                                                            attribute: .left,
//                                                            multiplier: 1,
//                                                            constant: 0)
//        let topWalletButtonConstraint = NSLayoutConstraint(item: walletButton,
//                                                            attribute: .top,
//                                                            relatedBy: .equal,
//                                                            toItem: backgroundView,
//                                                            attribute: .top,
//                                                            multiplier: 1,
//                                                            constant: 0)
//        let rightWalletButtonConstraint = NSLayoutConstraint(item: walletButton,
//                                                           attribute: .right,
//                                                           relatedBy: .equal,
//                                                           toItem: addButton,
//                                                           attribute: .left,
//                                                           multiplier: 1,
//                                                           constant: 0)
//        let rightAddButtonConstraint = NSLayoutConstraint(item: addButton,
//                                                           attribute: .right,
//                                                           relatedBy: .equal,
//                                                           toItem: backgroundView,
//                                                           attribute: .right,
//                                                           multiplier: 1,
//                                                           constant: 0)
//        let topAddButtonConstraint = NSLayoutConstraint(item: addButton,
//                                                          attribute: .top,
//                                                          relatedBy: .equal,
//                                                          toItem: backgroundView,
//                                                          attribute: .top,
//                                                          multiplier: 1,
//                                                          constant: 0)
//
//        walletButton.addConstraints([leftWalletButtonConstraint,
//                                    topWalletButtonConstraint,
//                                    rightWalletButtonConstraint])
//        addButton.addConstraints([rightAddButtonConstraint,
//                                topAddButtonConstraint])
        
        return backgroundView
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
        
        //button.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            walletTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            walletTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    @objc func handleAddToken(button: UIButton) {
        
        let section = button.tag
        
        let wallet = twoDimensionalTokensArray[section].tokens.first?.inWallet
        
        let searchTokenController = SearchTokenViewController(for: wallet)
        self.navigationController?.pushViewController(searchTokenController, animated: true)
        
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
        
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {return}
        let cell = tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
        
        guard let selectedCell = cell else {
            return
        }
        
        guard let indexPathTapped = walletTableView.indexPath(for: selectedCell) else { return }
        
        let token = twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]
        
        let tokenViewController = TokenViewController(
            wallet: token.inWallet,
            token: token.token,
            tokenBalance: selectedCell.balance.text ?? "0")
        self.navigationController?.pushViewController(tokenViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
