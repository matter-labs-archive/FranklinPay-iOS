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

    @IBOutlet weak var tokensTableView: BasicTableView!
    @IBOutlet weak var helpLabel: UILabel!

    var tokensList: [ERC20Token] = []
    var tokensAreAdded: [Bool] = []

    var searchController: UISearchController!

    var wallet: Wallet?

    let tokensService = TokensService()
    let alerts = Alerts()

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()

    convenience init(for wallet: Wallet) {
        self.init()
        self.wallet = wallet
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.firstMain
        self.hideKeyboardWhenTappedAround()
        self.setupNavigation()
        self.setupTableView()
        self.setupSearchController()
    }
    
    func setupNavigation() {
        self.title = "Search token"
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupTableView() {
        self.tokensTableView.delegate = self
        self.tokensTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.firstMain
        self.tokensTableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: "SearchTokenCell", bundle: nil)
        self.tokensTableView.register(nibSearch, forCellReuseIdentifier: "SearchTokenCell")
        let nibAddress = UINib.init(nibName: "AddressTableViewCell", bundle: nil)
        self.tokensTableView.register(nibAddress, forCellReuseIdentifier: "AddressTableViewCell")
        self.tokensList.removeAll()
        self.tokensAreAdded.removeAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tokensTableView.reloadData()
        makeHelpLabel(enabled: true)
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        tokensTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.white
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.searchController.hideKeyboardWhenTappedOutsideSearchBar(for: self)
    }

    @objc func scanTapped() {
        readerVC.delegate = self
        self.readerVC.modalPresentationStyle = .formSheet
        self.present(readerVC, animated: true)
    }

    @objc func textFromBuffer() {
        let searchBar = searchController.searchBar
        if let string = UIPasteboard.general.string {
            searchBar.text = string
            DispatchQueue.main.async { [weak self] in
                self?.searchBar(searchBar, textDidChange: string)
            }
        }
    }

    func isTokensListEmpty() -> Bool {
        if tokensList.isEmpty {
            return true
        }
        return false
    }

}

extension SearchTokenViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTokensListEmpty() {
            return 1
        } else {
            return tokensList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.rows.heights.tokens)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isTokensListEmpty() {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTokenCell",
                                                           for: indexPath) as? SearchTokenCell else {
                return UITableViewCell()
            }

            let network = CurrentNetwork.currentNetwork
            guard let wallet = wallet else {
                return cell
            }
            guard let tokensInWallet = try? wallet.getAllTokens(network: network) else {
                return cell
            }
            var isAdded = false
            for token in tokensInWallet where token == tokensList[indexPath.row] {
                isAdded = true
            }
            tokensAreAdded.append(isAdded)

            cell.configure(with: tokensList[indexPath.row], isAdded: isAdded)
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

        let token = self.tokensList[indexPath.row]
        let isAdded = tokensAreAdded[indexPath.row]
        guard let wallet = self.wallet else {
            return
        }
        do {
            if isAdded {
                try wallet.delete(token: token, network: CurrentNetwork.currentNetwork)
                CurrentToken.currentToken = Ether()
            } else {
                try wallet.add(token: token, network: CurrentNetwork.currentNetwork)
                CurrentToken.currentToken = token
            }
            DispatchQueue.main.async { [weak self] in
                self?.tokensTableView.reloadData()
            }
        } catch let error {
            alerts.showErrorAlert(for: self, error: error, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchTokenViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}

extension SearchTokenViewController: UISearchBarDelegate {

    func searchTokens(string: String) {
        guard let list = try? TokensService().getFullTokensList(for: string) else {
            emptyTokensList()
            return
        }
        updateTokensList(with: list)
    }

    func makeHelpLabel(enabled: Bool) {
        helpLabel.alpha = enabled ? 1 : 0
    }

    func emptyTokensList() {
        tokensList = []
        tokensAreAdded = []
        DispatchQueue.main.async { [weak self] in
            self?.tokensTableView.reloadData()
        }
    }

    func updateTokensList(with list: [ERC20Token]) {
        tokensAreAdded = []
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
        if searchBar.text != nil && searchBar.text! != "" && (!self.tokensList.isEmpty) {
//            let tokenToAdd = self.tokensList?.first
//            chosenToken = tokenToAdd
//            performSegue(withIdentifier: "addChosenToken", sender: self)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tokensTableView.setContentOffset(.zero, animated: true)
        emptyTokensList()
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
