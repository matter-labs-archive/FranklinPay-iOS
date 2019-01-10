//
//  WalletViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import BigInt

class WalletViewController: UIViewController {

    @IBOutlet weak var walletTableView: UITableView!
    @IBOutlet weak var blockchainControl: SegmentedControl!

    private var tokensService = TokensService()
    private var walletsService = WalletsService()
    private var twoDimensionalTokensArray: [ExpandableTableTokens] = []
    private var twoDimensionalUTXOsArray: [ExpandableTableUTXOs] = []
    private var chosenUTXOs: [TableUTXO] = []

    private let animation = AnimationController()
    private let alerts = Alerts()
    private let plasmaCoordinator = PlasmaCoordinator()
    private let etherCoordinator = EtherCoordinator()

    private enum Blockchain: Int {
        case ether = 0
        case plasma = 1
    }

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
        #selector(self.handleRefresh(_:)),
                for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.selectedItem?.title = nil
        self.setupTableView()
    }
    
    func setupTableView() {
        let nibToken = UINib.init(nibName: "TokenCell", bundle: nil)
        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        self.walletTableView.tableFooterView = UIView()
        self.walletTableView.addSubview(self.refreshControl)
        self.walletTableView.register(nibToken, forCellReuseIdentifier: "TokenCell")
        twoDimensionalTokensArray.removeAll()
        twoDimensionalUTXOsArray.removeAll()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Wallets"
        self.tabBarController?.tabBar.selectedItem?.title = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTable()
    }

//    func unselectAllTokens() {
//        var indexPath = IndexPath(row: 0, section: 0)
//        for wallet in twoDimensionalTokensArray {
//            for _ in wallet.tokens {
//                self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].isSelected = false
//                if let cell = self.walletTableView.cellForRow(at: indexPath) as? TokenCell {
//                    cell.changeSelectButton(isSelected: false)
//                }
//                indexPath.row += 1
//            }
//            indexPath.section += 1
//            indexPath.row = 0
//        }
//    }

    func unselectAllUTXOs() {
        var indexPath = IndexPath(row: 0, section: 0)
        for wallet in twoDimensionalUTXOsArray {
            for _ in wallet.utxos {
                self.twoDimensionalUTXOsArray[indexPath.section].utxos[indexPath.row].isSelected = false
                guard let cell = self.walletTableView.cellForRow(at: indexPath) as? UTXOCell else {return}
                cell.changeSelectButton(isSelected: false)
                indexPath.row += 1
            }
            indexPath.section += 1
            indexPath.row = 0
        }
    }

//    func selectToken(cell: UITableViewCell) {
//        unselectAllTokens()
//        guard let cell = cell as? TokenCell else {return}
//        guard let indexPathTapped = self.walletTableView.indexPath(for: cell) else {return}
//        let token = self.twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]
//        CurrentWallet.currentWallet = token.inWallet
//        CurrentToken.currentToken = token.token
//        self.twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row].isSelected = true
//        cell.changeSelectButton(isSelected: true)
//    }

    func selectUTXO(cell: UITableViewCell) {
        guard let cell = cell as? UTXOCell else {return}
        guard let indexPathTapped = self.walletTableView.indexPath(for: cell) else {return}
        let utxo = self.twoDimensionalUTXOsArray[indexPathTapped.section].utxos[indexPathTapped.row]
        let wallet = utxo.inWallet
        let selected = self.twoDimensionalUTXOsArray[indexPathTapped.section].utxos[indexPathTapped.row].isSelected
        if selected {
            for i in 0..<self.chosenUTXOs.count where self.chosenUTXOs[i] == utxo {
                self.chosenUTXOs.remove(at: i)
                break
            }
        } else {
            guard self.chosenUTXOs.count < 2 else {
                self.alerts.showErrorAlert(for: self,
                                           error: "Can't select more than 2 utxos",
                                           completion: nil)
            }
            if let firstUTXO = self.chosenUTXOs.first {
                guard wallet == firstUTXO.inWallet else {
                    self.alerts.showErrorAlert(for: self,
                                               error: "UTXOs must be in one wallet",
                                               completion: nil)
                }
                self.chosenUTXOs.append(utxo)
            } else {
                self.chosenUTXOs.append(utxo)
            }
        }
        self.twoDimensionalUTXOsArray[indexPathTapped.section].utxos[indexPathTapped.row].isSelected = !selected
        cell.changeSelectButton(isSelected: !selected)
        if self.chosenUTXOs.count == 2 {
            self.alerts.showAccessAlert(for: self, with: "Merge UTXOs?") { [unowned self] (result) in
                if result {
                    guard let tx = try? self.plasmaCoordinator.formMergeUTXOsTransaction(for: wallet, utxos: self.chosenUTXOs) else {
                        self.alerts.showErrorAlert(for: self, error: "Can't merge UTXOs", completion: nil)
                    }
                    self.enterPincode(for: tx)
                }
            }
        }
    }

    func enterPincode(for transaction: PlasmaTransaction) {
        //need to wallet.getPassword
        let enterPincode = PincodeViewController(operation: .approvement)
        self.navigationController?.pushViewController(enterPincode, animated: true)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.updateTable()
    }

    func reloadDataInTable() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.walletTableView.reloadData()
        }
    }

    func updateTable() {
        DispatchQueue.global().async { [weak self] in
            switch self?.blockchainControl.selectedSegmentIndex {
            case Blockchain.ether.rawValue:
                self?.updateEtherBlockchain()
            default:
                self?.updatePlasmaBlockchain()
            }
        }
    }
    
    func updatePlasmaBlockchain() {
        let utxos = self.plasmaCoordinator.getWalletsAndUTXOs()
        self.twoDimensionalUTXOsArray = utxos
        self.reloadDataInTable()
    }

    func updateEtherBlockchain() {
        let tokens = self.etherCoordinator.getWalletsAndTokens()
        self.twoDimensionalTokensArray = tokens
        self.reloadDataInTable()
        self.updateTokensBalances()
    }
    
    func updateTokensBalances() {
        guard !self.twoDimensionalTokensArray.isEmpty else {return}
        var indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.global().async { [weak self] in
            for wallet in (self?.twoDimensionalTokensArray)! {
                DispatchQueue.global().async {
                    for token in wallet.tokens {
                        DispatchQueue.global().async {
                            if let balance = self?.etherCoordinator.getBalance(for: token.token, wallet: token.inWallet) {
                                self?.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].balance = balance
                                DispatchQueue.main.async {
                                    self?.refreshControl.endRefreshing()
                                    self?.walletTableView.reloadRows(at: [indexPath], with: .none)
                                }
                                if let balanceInDollars = self?.etherCoordinator.getBalanceInDollars(for: token.token, withBalance: balance) {
                                    self?.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].balanceInDollars = balanceInDollars
                                    DispatchQueue.main.async {
                                        self?.refreshControl.endRefreshing()
                                        self?.walletTableView.reloadRows(at: [indexPath], with: .none)
                                    }
                                }
                            }
                        }
                        indexPath.row += 1
                    }
                }
                indexPath.section += 1
            }
        }
    }

    @IBAction func blockchainChanged(_ sender: UISegmentedControl) {
        self.updateTable()
    }
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource, TableHeaderDelegate {
    
    func didPressAdd(sender: UIButton) {
        let section = sender.tag
        guard let wallet = self.twoDimensionalTokensArray[section].tokens.first?.inWallet else {
            self.alerts.showErrorAlert(for: self, error: "Can't select wallet", completion: nil)
        }
        let searchTokenController = SearchTokenViewController(for: wallet)
        self.navigationController?.pushViewController(searchTokenController, animated: true)
    }
    
    func didPressExpand(sender: UIButton) {
        let section = sender.tag
        var indexPaths = [IndexPath]()
        let isExpanded: Bool
        
        switch self.blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            for row in self.twoDimensionalTokensArray[section].tokens.indices {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
            
            isExpanded = self.twoDimensionalTokensArray[section].isExpanded
            self.twoDimensionalTokensArray[section].isExpanded = !isExpanded
        default:
            for row in self.twoDimensionalUTXOsArray[section].utxos.indices {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
            
            isExpanded = self.twoDimensionalUTXOsArray[section].isExpanded
            self.twoDimensionalUTXOsArray[section].isExpanded = !isExpanded
        }
        if isExpanded {
            self.walletTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            self.walletTableView.insertRows(at: indexPaths, with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let background: UIView
        switch self.blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            background = TableHeader(for: (self.twoDimensionalTokensArray[section].tokens.first?.inWallet)!, plasma: false, section: section)
        default:
            background = TableHeader(for: (self.twoDimensionalUTXOsArray[section].utxos.first?.inWallet)!, plasma: true, section: section)
        }
        return background
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            return self.twoDimensionalTokensArray.count
        default:
            return self.twoDimensionalUTXOsArray.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rows.heights.wallets
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headers.heights.wallets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            if !self.twoDimensionalTokensArray[section].isExpanded {
                return 0
            }

            return self.twoDimensionalTokensArray[section].tokens.count
        default:
            if !self.twoDimensionalUTXOsArray[section].isExpanded {
                return 0
            }

            return self.twoDimensionalUTXOsArray[section].utxos.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell",
                                                           for: indexPath) as? TokenCell else {
                                                            return UITableViewCell()
            }
            cell.link = self
            let tableToken = self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row]
            cell.configure(token: tableToken)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UTXOCell",
                                                           for: indexPath) as? UTXOCell else {
                                                            return UITableViewCell()
            }
            cell.link = self
            let tableUtxo = self.twoDimensionalUTXOsArray[indexPath.section].utxos[indexPath.row]
            cell.configure(utxo: tableUtxo)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch self.blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
                return
            }
            let cell = tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell

            guard let selectedCell = cell else {
                return
            }

            guard let indexPathTapped = self.walletTableView.indexPath(for: selectedCell) else {
                return
            }

            let tableToken = self.twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]

            let tokenViewController = TokenViewController(for: tableToken)
            self.navigationController?.pushViewController(tokenViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard self.blockchainControl.selectedSegmentIndex == Blockchain.ether.rawValue else {return}
        let token = self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].token
        let wallet = self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].inWallet
        let network = CurrentNetwork.currentNetwork
        let isEtherToken = token == Ether()
        let plasmaBlockchain = self.blockchainControl.selectedSegmentIndex == Blockchain.plasma.rawValue
        if isEtherToken || plasmaBlockchain {
            return
        }
        if editingStyle == .delete {
            do {
                try wallet.delete(token: token, network: network)
                self.updateTable()
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: error, completion: nil)
            }
        }
    }
}
