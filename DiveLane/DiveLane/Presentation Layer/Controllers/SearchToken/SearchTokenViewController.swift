//
//  SearchTokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class SearchTokenViewController: UIViewController {

    @IBOutlet weak var tokensTableView: UITableView!
    
    var tokensList: [ERC20TokenModel]?
    var tokensIsAdded: [Bool]?
    
    var searchController: UISearchController!
    
    var wallet: KeyWalletModel?
    
    convenience init (for wallet: KeyWalletModel?) {
        self.init()
        self.wallet = wallet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if wallet == nil {
            wallet = KeysService().selectedWallet()
        }
        
        self.tokensTableView.delegate = self
        self.tokensTableView.dataSource = self
        self.tokensTableView.tableFooterView = UIView()
        
        let nibSearch = UINib.init(nibName: "SearchTokenCell", bundle: nil)
        self.tokensTableView.register(nibSearch, forCellReuseIdentifier: "SearchTokenCell")
        let nibAddress = UINib.init(nibName: "AddressTableViewCell", bundle: nil)
        self.tokensTableView.register(nibAddress, forCellReuseIdentifier: "AddressTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tokensTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.darkText
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Search token"
        
    }

}

extension SearchTokenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tokensList != nil {
            return (tokensList?.count)!
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tokensList != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTokenCell", for: indexPath) as! SearchTokenCell
            //let added = tokenIsAdded![indexPath.row]
            cell.configure(with: (tokensList?[indexPath.row])!, isAdded: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentWallet = wallet else {
            return
        }
        //TODO: - works just this way for now. need to work with addToken()
        let networkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
        LocalDatabase().saveCustomToken(with: self.tokensList?[indexPath.row], forWallet: currentWallet, forNetwork: networkID, completion: { (error) in
            if error == nil {
                print("wow")
            }
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension SearchTokenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension SearchTokenViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            
            tokensList = nil
            tokensTableView.reloadData()
            
        } else {
            
            let token = searchText
            print(token)
            
            TokensService().getFullTokensList(for: token, completion: { (result) in
                if let list = result {
                    self.tokensIsAdded = []
                    self.tokensList = list
                    for _ in 0...list.count-1 {
                        self.tokensIsAdded?.append(false)
                    }
                    DispatchQueue.main.async {
                        self.tokensTableView.reloadData()
                    }
                    //self.updateListForAlreadyAddedTokens()
                } else {
                    self.tokensList = nil
                    self.tokensIsAdded = nil
                    DispatchQueue.main.async {
                        self.tokensTableView.reloadData()
                    }
                    
                }
            })
            
        }
    }
    
//    func updateListForAlreadyAddedTokens() {
//        let dataQueue = DispatchQueue.global(qos: .background)
//        dataQueue.async {
//            self.walletData.update(callback: { (etherToken, transactions, availableTokens) in
//                if self.tokensList != nil{
//                    var i = 0
//                    for token in self.tokensList! {
//                        for availableToken in availableTokens {
//                            if token == availableToken {
//                                self.tokensAvailability![i] = true
//                                break
//                            }
//                        }
//                        i += 1
//                    }
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//
//            })
//        }
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil && searchBar.text! != "" && (self.tokensList != nil) {
//            let tokenToAdd = self.tokensList?.first
//            chosenToken = tokenToAdd
//            performSegue(withIdentifier: "addChosenToken", sender: self)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tokensTableView.setContentOffset(.zero, animated: true)
        self.tokensList = nil
        self.tokensTableView.reloadData()
        //self.getPeepsList(older: false)
    }
}
