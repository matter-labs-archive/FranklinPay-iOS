//
//  WalletViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import PlasmaSwiftLib
import web3swift
import struct EthereumAddress.EthereumAddress

class WalletViewController: UIViewController {

    @IBOutlet weak var walletTableView: UITableView!
    @IBOutlet weak var blockchainControl: UISegmentedControl!

    let conversionService = FiatServiceImplementation.service

    var localDatabase: ILocalDatabase?
    var keysService: IKeysService?
    var wallets: [KeyWalletModel]?
    var twoDimensionalTokensArray: [ExpandableTableTokens] = []
    var twoDimensionalUTXOsArray: [ExpandableTableUTXOs] = []

    let animation = AnimationController()

    let design = DesignElements()

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
        animation.waitAnimation(isEnabled: true, notificationText: "Loading initial data", on: self.view)
        self.tabBarController?.tabBar.selectedItem?.title = nil
        let nibToken = UINib.init(nibName: "TokenCell", bundle: nil)
        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        self.walletTableView.tableFooterView = UIView()
        self.walletTableView.addSubview(self.refreshControl)
        self.walletTableView.register(nibToken, forCellReuseIdentifier: "TokenCell")
        self.navigationItem.setRightBarButton(settingsWalletBarItem(), animated: false)
    }

    func initDatabase(complection: @escaping () -> Void) {
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
        updateTable()
    }

    func unselectAll() {
        var indexPath = IndexPath(row: 0, section: 0)
        for wallet in twoDimensionalTokensArray {
            for _ in wallet.tokens {
                self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].isSelected = false
                guard let cell = walletTableView.cellForRow(at: indexPath) as? TokenCell else {return}
                cell.changeSelectButton(isSelected: false)
                indexPath.row += 1
            }
            indexPath.section += 1
            indexPath.row = 0
        }
    }

    func selectToken(cell: UITableViewCell) {
        unselectAll()
        guard let cell = cell as? TokenCell else {return}
        guard let indexPathTapped = walletTableView.indexPath(for: cell) else {return}
        let token = twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]
        print(token)
        CurrentToken.currentToken = token.token
        localDatabase?.selectWallet(wallet: token.inWallet, completion: { [weak self] in
            self?.twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row].isSelected = true
            cell.changeSelectButton(isSelected: true)
        })
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        updateTable()
    }

    func reloadDataInTable() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.walletTableView.reloadData()
            self?.animation.waitAnimation(isEnabled: false, notificationText: "Loading initial data", on: (self?.view)!)
        }
    }

    func updateTable() {
        twoDimensionalTokensArray.removeAll()
        twoDimensionalUTXOsArray.removeAll()
        reloadDataInTable()
        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            DispatchQueue.global().async { [weak self] in
                self?.updateEtherBlockchain()
            }
        default:
            DispatchQueue.global().async { [weak self] in
                self?.updatePlasmaBlockchain()
            }
        }
    }

    func settingsWalletBarItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(image: UIImage(named: "settings_blue"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(settingsWallet))
        return addButton
    }

    @objc func settingsWallet() {
        let walletsViewController = WalletsViewController()
        self.navigationController?.pushViewController(walletsViewController, animated: true)
    }

    @IBAction func addWallet(_ sender: UIButton) {
        let addWalletViewController = AddWalletViewController(isNavigationBarNeeded: true)
        self.navigationController?.pushViewController(addWalletViewController, animated: true)
    }

    func getTokensListForEtherBlockchain(completion: @escaping () -> Void) {
        guard let wallets = wallets else {
            return
        }
        let networkID = CurrentNetwork().getNetworkID()
        for wallet in wallets {
            let tokensForWallet = localDatabase?.getAllTokens(for: wallet, forNetwork: networkID)
            let isSelectedWallet = wallet == keysService?.selectedWallet() ? true : false
            if let tokens = tokensForWallet {

                let expandableTokens = ExpandableTableTokens(isExpanded: isSelectedWallet,
                        tokens: tokens.map {
                            TableToken(token: $0,
                                    inWallet: wallet,
                                    isSelected: ($0 == CurrentToken.currentToken) && isSelectedWallet)
                        })
                twoDimensionalTokensArray.append(expandableTokens)
                completion()
            }
        }
    }

    func updatePlasmaBlockchain() {
        guard let wallets = wallets else {return}
        guard let network = CurrentNetwork.currentNetwork else {return}
        for wallet in wallets {
            guard let ethAddress = EthereumAddress(wallet.address) else {return}
            let mainnet = network.chainID == Networks.Mainnet.chainID
            let testnet = !mainnet && network.chainID == Networks.Rinkeby.chainID
            if !testnet && !mainnet {return}
            let semaphore = DispatchSemaphore(value: 0)
            ServiceUTXO().getListUTXOs(for: ethAddress, onTestnet: testnet) { [weak self] (result) in
                switch result {
                case .Success(let utxos):
                    let expandableUTXOS = ExpandableTableUTXOs(isExpanded: true,
                                                               utxos: utxos.map {
                                                                TableUTXO(utxo: $0,
                                                                          inWallet: wallet)
                    })
                    self?.twoDimensionalUTXOsArray.append(expandableUTXOS)
                case .Error(let error):
                    print(error.localizedDescription)
                }
                if wallet == wallets.last {
                    self?.reloadDataInTable()
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func updateEtherBlockchain() {
        initDatabase { [weak self] in
            self?.twoDimensionalTokensArray.removeAll()
            self?.getTokensListForEtherBlockchain { [weak self] in
                self?.reloadDataInTable()
            }
        }
    }

    @IBAction func blockchainChanged(_ sender: UISegmentedControl) {
        updateTable()
    }

}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {

    func backgroundForHeaderInEtherBlockchain(section: Int) -> UIView {
        let backgroundView = design.tableViewHeaderBackground(in: self.view)

        let walletButton = design.tableViewHeaderWalletButton(in: self.view,
                                                              withTitle: "Wallet \(twoDimensionalTokensArray[section].tokens.first?.inWallet.name ?? "")",
            withTag: section)
        walletButton.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        backgroundView.addSubview(walletButton)

        let addButton = design.tableViewAddTokenButton(in: self.view, withTag: section)
        addButton.addTarget(self, action: #selector(handleAddToken), for: .touchUpInside)
        backgroundView.addSubview(addButton)

        return backgroundView
    }

    func backgroundForHeaderInPlasmaBlockchain(section: Int) -> UIView {
        let backgroundView = design.tableViewHeaderBackground(in: self.view)

        let walletButton = design.tableViewHeaderWalletButton(in: self.view,
                                                              withTitle: "Wallet \(twoDimensionalUTXOsArray[section].utxos.first?.inWallet.name ?? "")",
            withTag: section)
        walletButton.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        backgroundView.addSubview(walletButton)

        return backgroundView
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let background: UIView
        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            background = backgroundForHeaderInEtherBlockchain(section: section)
        default:
            background = backgroundForHeaderInPlasmaBlockchain(section: section)
        }
        return background
    }

    @objc func handleExpandClose(button: UIButton) {

        let section = button.tag

        var indexPaths = [IndexPath]()

        let isExpanded: Bool

        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            for row in twoDimensionalTokensArray[section].tokens.indices {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }

            isExpanded = twoDimensionalTokensArray[section].isExpanded
            twoDimensionalTokensArray[section].isExpanded = !isExpanded
        default:
            for row in twoDimensionalUTXOsArray[section].utxos.indices {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }

            isExpanded = twoDimensionalUTXOsArray[section].isExpanded
            twoDimensionalUTXOsArray[section].isExpanded = !isExpanded
        }
        if isExpanded {
            walletTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            walletTableView.insertRows(at: indexPaths, with: .fade)
        }
    }

    @objc func handleAddToken(button: UIButton) {
        let section = button.tag
        let wallet = twoDimensionalTokensArray[section].tokens.first?.inWallet
        let token = twoDimensionalTokensArray[section].tokens.first
        LocalDatabase().selectWallet(wallet: wallet) {
            CurrentToken.currentToken = token?.token
            let searchTokenController = SearchTokenViewController(for: wallet)
            self.navigationController?.pushViewController(searchTokenController, animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            return twoDimensionalTokensArray.count
        default:
            return twoDimensionalUTXOsArray.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            if !twoDimensionalTokensArray[section].isExpanded {
                return 0
            }

            return twoDimensionalTokensArray[section].tokens.count
        default:
            if !twoDimensionalUTXOsArray[section].isExpanded {
                return 0
            }

            return twoDimensionalUTXOsArray[section].utxos.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell",
                                                       for: indexPath) as? TokenCell else {
                                                        return UITableViewCell()
        }
        cell.link = self

        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            let token = twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row]
            cell.configureForEtherBlockchain(token: token.token,
                                             forWallet: token.inWallet,
                                             isSelected: token.isSelected)
        default:
            let utxo = twoDimensionalUTXOsArray[indexPath.section].utxos[indexPath.row]
            cell.configureForPlasmaBlockchain(utxo: utxo.utxo, forWallet: utxo.inWallet)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch blockchainControl.selectedSegmentIndex {
        case Blockchain.ether.rawValue:
            guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
                return
            }
            let cell = tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell

            guard let selectedCell = cell else {
                return
            }

            guard let indexPathTapped = walletTableView.indexPath(for: selectedCell) else {
                return
            }

            let token = twoDimensionalTokensArray[indexPathTapped.section].tokens[indexPathTapped.row]

            let tokenViewController = TokenViewController(
                wallet: token.inWallet,
                token: token.token,
                tokenBalance: selectedCell.balance.text ?? "0")
            self.navigationController?.pushViewController(tokenViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard blockchainControl.selectedSegmentIndex == Blockchain.ether.rawValue else {return}
        let etherToken = twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].token == ERC20TokenModel(isEther: true)
        let plasmaBlockchain = blockchainControl.selectedSegmentIndex == Blockchain.ether.rawValue
        if etherToken || plasmaBlockchain {
            return
        }
        if editingStyle == .delete {
            let networkID = CurrentNetwork().getNetworkID()
            localDatabase?.deleteToken(
                token: twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].token,
                forWallet: twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row].inWallet,
                forNetwork: networkID,
                completion: { [weak self] (error) in
                if error == nil {
                    self?.updateTable()
                }
            })
        }
    }

}
