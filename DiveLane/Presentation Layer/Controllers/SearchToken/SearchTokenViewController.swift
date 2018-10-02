//
//  SearchTokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader

class SearchTokenViewController: UIViewController {

    @IBOutlet weak var tokensTableView: UITableView!
    @IBOutlet weak var helpLabel: UILabel!
    
    var tokensList: [ERC20TokenModel]?
    var tokensIsAdded: [Bool]?

    var searchController: UISearchController!

    var wallet: KeyWalletModel?
    
    let interactor = Interactor()
    
    lazy var readerVC:QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes:[.qr],captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()

    convenience init(for wallet: KeyWalletModel?) {
        self.init()
        self.wallet = wallet
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.title = "Search token"

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
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor.darkText
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tokensTableView.reloadData()

    }
    
    @objc func scanTapped() {
        readerVC.delegate = self
        self.readerVC.modalPresentationStyle = .formSheet
        self.present(readerVC, animated: true)
    }
    
    @objc func textFromBuffer() {
        let searchBar = searchController.searchBar
        if let string = UIPasteboard.general.string  {
            searchController.searchBar.text = string
            DispatchQueue.main.async { [weak self] in
                self?.searchBar(searchBar, textDidChange: string)
            }
        }
    }
    
    func isTokensListEmpty() -> Bool {
        if tokensList == nil || tokensList == [] {
            return true
        }
        return false
    }

}

extension SearchTokenViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.searchController.searchBar.endEditing(true)
    }
}

extension SearchTokenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTokensListEmpty() {
            return 1
        } else {
            return (tokensList?.count)!
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isTokensListEmpty() {
            
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
            cell.qr.addTarget(self, action: #selector(self.scanTapped), for: .touchUpInside)
            cell.paste.addTarget(self, action: #selector(self.textFromBuffer), for: .touchUpInside)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let token = self.tokensList?[indexPath.row] else {
            return
        }
        
//        change(token: token, fromCurrentStatus: tokensIsAdded?[indexPath.row] ?? true)
        
        let tokenInfoViewController = TokenInfoViewController(token: token,
                                                              isAdded: tokensIsAdded?[indexPath.row] ?? true,
                                                              interactor: interactor)
        
        tokenInfoViewController.transitioningDelegate = self
        
        self.present(tokenInfoViewController, animated: true, completion: nil)
        
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

extension SearchTokenViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
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

extension SearchTokenViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension SearchTokenViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let searchBar = searchController.searchBar
        let searchText = result.value.lowercased()
        self.searchController.searchBar.text = searchText
        reader.dismiss(animated: true)
        DispatchQueue.main.async { [weak self] in
            self?.searchBar(searchBar, textDidChange: searchText)
        }
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true)
    }
    
}
