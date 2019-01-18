//
//  SearchTokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader

class SearchTokenViewController: BasicViewController {

    @IBOutlet weak var tokensTableView: BasicTableView!
    @IBOutlet weak var helpLabel: UILabel!
    
    var ratesUpdating = false

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
    }
    
    func clearData() {
        self.tokensList.removeAll()
        self.tokensAreAdded.removeAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    func searchTokens(string: String) {
        DispatchQueue.global().async { [unowned self] in
            guard let list = try? self.tokensService.getFullTokensList(for: string) else {
                self.emptyTokensList()
                return
            }
            self.updateTokensList(with: list, completion: {
                self.reloadTableData()
                self.updateRates {
                    self.reloadTableDataWithDelay() 
                }
            })
        }
    }
    
    func updateRates(comletion: @escaping () -> Void) {
        guard !self.ratesUpdating else { return }
        self.ratesUpdating = true
        let first10List: [ERC20Token]
        if self.tokensList.count > 10 {
            first10List = Array(self.tokensList.prefix(upTo: 10))
        } else {
            first10List = self.tokensList
        }
        for token in first10List {
            do {
                _ = try token.updateRateAndChange()
            } catch {
                continue
            }
        }
        self.ratesUpdating = false
        comletion()
    }
    
    func makeHelpLabel(enabled: Bool) {
        helpLabel.alpha = enabled ? 1 : 0
    }
    
    func emptyTokensList() {
        clearData()
        reloadTableData()
    }
    
    func reloadTableData() {
        DispatchQueue.main.async { [unowned self] in
            self.tokensTableView.reloadData()
        }
    }
    
    func reloadTableDataWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [unowned self] in
            self.tokensTableView.reloadData()
        })
    }
    
    func updateTokensList(with list: [ERC20Token], completion: @escaping () -> Void) {
        clearData()
        let network = CurrentNetwork.currentNetwork
        if let wallet = wallet, let tokensInWallet = try? wallet.getAllTokens(network: network) {
            tokensList = list
            for tokenFromList in tokensList {
                var isAdded = false
                for tokenFromWallet in tokensInWallet where tokenFromList == tokenFromWallet {
                    isAdded = true
                }
                tokensAreAdded.append(isAdded)
            }
        }
        completion()
    }
}

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
            return CGFloat(Constants.rows.heights.additionalButtons)
        } else {
            return CGFloat(Constants.rows.heights.tokens)
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
            cell.qr.addTarget(self, action: #selector(self.scanTapped), for: .touchUpInside)
            cell.paste.addTarget(self, action: #selector(self.textFromBuffer), for: .touchUpInside)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is AddressTableViewCell {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let token = self.tokensList[indexPath.row]
        let isAdded = tokensAreAdded[indexPath.row]
        guard let wallet = self.wallet else {
            return
        }
        do {
            if isAdded {
                try wallet.delete(token: token, network: CurrentNetwork.currentNetwork)
                tokensAreAdded[indexPath.row] = false
                CurrentToken.currentToken = Ether()
            } else {
                try wallet.add(token: token, network: CurrentNetwork.currentNetwork)
                tokensAreAdded[indexPath.row] = true
            }
            self.reloadTableData()
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
