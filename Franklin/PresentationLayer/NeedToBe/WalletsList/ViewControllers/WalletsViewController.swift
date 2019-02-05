////
////  WalletsViewController.swift
////  DiveLane
////
////  Created by NewUser on 13/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class WalletsViewController: BasicViewController {
//
//    @IBOutlet weak var tableView: BasicTableView!
//    
//    let walletsCoordinator = WalletsCoordinator()
//    let alerts = Alerts()
//
//    var wallets: [TableWallet] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.setupNavigation()
//        self.setupTableView()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.updateTable()
//    }
//    
//    func setupNavigation() {
//        navigationItem.title = "Wallets"
//        navigationController?.navigationBar.isHidden = false
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
//    }
//    
//    private func setupTableView() {
//        let nibToken = UINib.init(nibName: "WalletCell", bundle: nil)
//        tableView.delegate = self
//        tableView.dataSource = self
//        let footerView = UIView()
//        footerView.backgroundColor = Colors.background
//        tableView.tableFooterView = footerView
//        tableView.register(nibToken, forCellReuseIdentifier: "WalletCell")
//        wallets.removeAll()
//    }
//    
//    func updateTable() {
//        DispatchQueue.global().async { [weak self] in
//            self?.getWallets()
//        }
//    }
//    
//    private func getWallets() {
//        let walletsArray = self.walletsCoordinator.getWallets()
//        self.wallets = walletsArray
//        self.reloadDataInTable()
//        self.updateWalletsBalances {
//            self.reloadDataInTable()
//        }
//    }
//    
//    func reloadDataInTable() {
//        DispatchQueue.main.async { [weak self] in
//            self?.tableView.reloadData()
//        }
//    }
//    
//    func updateWalletsBalances(completion: @escaping () -> Void) {
//        guard !self.wallets.isEmpty else {return}
//        var indexPath = IndexPath(row: 0, section: 0)
//        DispatchQueue.global().sync { [unowned self] in
//            for wallet in self.wallets {
//                let dollarsBalance = self.walletsCoordinator.getDollarsBalance(for: wallet.wallet)
//                self.wallets[indexPath.row].balanceUSD = dollarsBalance
//                
////                DispatchQueue.main.async {
////                    self.tableView.reloadRows(at: [indexPath], with: .none)
////                }
//                indexPath.row += 1
//            }
//            completion()
//        }
//    }
//
//    @objc func addButtonTapped() {
//        let addWalletViewController = AddWalletViewController(isNavigationBarNeeded: true)
//        self.navigationController?.pushViewController(addWalletViewController, animated: true)
//    }
//    
//    func deleteWallet(in indexPath: IndexPath) {
//        self.alerts.showAccessAlert(for: self, with: "Delete wallet \(wallets[indexPath.row].wallet.name)?") { [unowned self] (answer) in
//            if answer {
//                do {
//                    if self.wallets.count == 1 {
//                        try self.wallets[indexPath.row].wallet.delete()
//                        CurrentWallet.currentWallet = nil
//                        CurrentToken.currentToken = nil
//                        let vc = AddWalletViewController(isNavigationBarNeeded: false)
//                        vc.view.backgroundColor = Colors.background
//                        self.present(vc, animated: true, completion: nil)
//                    } else {
//                        try self.wallets[indexPath.row].wallet.delete()
//                        DispatchQueue.main.async {
//                            self.tableView.deleteRows(at: [indexPath], with: .left)
//                        }
//                        self.wallets.remove(at: indexPath.row)
//                        CurrentWallet.currentWallet = self.wallets.first?.wallet
//                        self.updateTable()
//                    }
//                } catch let error {
//                    self.alerts.showErrorAlert(for: self, error: error, completion: nil)
//                }
//            }
//        }
//    }
//    
//    func showInfoActions(for wallet: TableWallet) {
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let showPrivateKeyAction = UIAlertAction(title: "Show private key", style: .default) { [weak self] (_) in
//            let vc = PrivateKeyViewController(for: wallet.wallet)
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }
//        let copyPublicKeyAction = UIAlertAction(title: "Copy public key", style: .default) { [weak self] (_) in
//            UIPasteboard.general.string = wallet.wallet.address
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//        }
//        alertController.addAction(showPrivateKeyAction)
//        alertController.addAction(copyPublicKeyAction)
//        alertController.addAction(cancelAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
//}
//
//extension WalletsViewController: WalletCellDelegate {
//    func walletInfoTapped(_ sender: WalletCell) {
//        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
//        let wallet = wallets[tappedIndexPath.row]
//        showInfoActions(for: wallet)
//    }
//}
//
//extension WalletsViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return wallets.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell else {
//            return UITableViewCell()
//        }
//        cell.configureCell(model: wallets[indexPath.row])
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        CurrentWallet.currentWallet = wallets[indexPath.row].wallet
//        self.tableView.deselectRow(at: indexPath, animated: true)
//        self.reloadDataInTable()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(Constants.rows.heights.wallets)
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            self.deleteWallet(in: indexPath)
//        }
//    }
//}
