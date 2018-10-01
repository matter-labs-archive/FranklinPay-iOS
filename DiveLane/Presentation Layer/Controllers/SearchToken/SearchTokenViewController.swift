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
    @IBOutlet weak var helpLabel: UILabel!
    
    var tokensList: [ERC20TokenModel]?
    var tokensIsAdded: [Bool]?

    var searchController: UISearchController!

    var wallet: KeyWalletModel?

    convenience init(for wallet: KeyWalletModel?) {
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
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTokenCell",
                                                           for: indexPath) as? SearchTokenCell else {
                return UITableViewCell()
            }

            let networkID = CurrentNetwork().getNetworkID()
            guard let wallet = wallet else {
                return cell
            }
            let tokensInWallet = LocalDatabase().getAllTokens(for: wallet, forNetwork: networkID)
            var isAdded = false
            for token in tokensInWallet where token == (tokensList?[indexPath.row])! {
                isAdded = true
            }
            tokensIsAdded?.append(isAdded)

            cell.configure(with: (tokensList?[indexPath.row])!, isAdded: isAdded)
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell",
                                                           for: indexPath) as? AddressTableViewCell else {
                                                            return UITableViewCell()
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let token = self.tokensList?[indexPath.row] else {
            return
        }
        
        change(token: token, fromCurrentStatus: tokensIsAdded?[indexPath.row] ?? true)
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    func change(token: ERC20TokenModel, fromCurrentStatus isEnabled: Bool) {
        
        guard let currentWallet = wallet else {
            return
        }
        
        let networkID = CurrentNetwork().getNetworkID()
        
        tokensIsAdded = []
        
        if isEnabled {
            LocalDatabase().deleteToken(token: token, forWallet: currentWallet, forNetwork: networkID, completion: { [weak self] (error) in
                if error == nil {
                    
                    DispatchQueue.main.async {
                        self?.tokensTableView.reloadData()
                    }
                }
            })
        } else {
            LocalDatabase().saveCustomToken(with: token, forWallet: currentWallet, forNetwork: networkID, completion: { [weak self] (error) in
                if error == nil {
                    
                    DispatchQueue.main.async {
                        self?.tokensTableView.reloadData()
                    }
                }
            })
        }
    }

}

extension SearchTokenViewController: UISearchBarDelegate {

    func searchTokens(string: String) {

        TokensService().getFullTokensList(for: string, completion: { [weak self] (result) in
            if let list = result {
                self?.updateTokensList(with: list)
            } else {
                self?.emptyTokensList()
            }
        })
    }
    
    func makeHelpLabel(enabled: Bool) {
        helpLabel.alpha = enabled ? 1 : 0
    }
    
    func emptyTokensList() {
        tokensList = []
        tokensIsAdded = nil
        DispatchQueue.main.async { [weak self] in
            self?.tokensTableView.reloadData()
        }
    }
    
    func updateTokensList(with list: [ERC20TokenModel]) {
        tokensIsAdded = []
        tokensList = list
        DispatchQueue.main.async { [weak self] in
            self?.tokensTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        guard let searchText = searchBar.text else {
            emptyTokensList()
            makeHelpLabel(enabled: true)
            return
        }
        
        if searchText == "" {
            
            emptyTokensList()
            makeHelpLabel(enabled: true)
            
        } else {
            
            let token = searchText
            makeHelpLabel(enabled: false)
            searchTokens(string: token)
            
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" {

            emptyTokensList()
            makeHelpLabel(enabled: true)

        } else {
            
            let token = searchText
            makeHelpLabel(enabled: false)
            searchTokens(string: token)

        }
    }


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
    }
}
