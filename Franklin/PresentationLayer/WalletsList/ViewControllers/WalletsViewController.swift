//
//  WalletsViewController.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class WalletsViewController: BasicViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var tableView: BasicTableView!
    
    // MARK: - Internal vars
    
    internal let walletsCoordinator = WalletsCoordinator()
    internal let alerts = Alerts()

    internal var wallets: [TableWallet] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigation(hidden: false)
        updateTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigation(hidden: true)
    }
    
    // MARK: - Main setup
    
    func setNavigation(hidden: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: true)
        navigationController?.makeClearNavigationController()
    }
    
    private func setupTableView() {
        let nibToken = UINib.init(nibName: "WalletCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        tableView.tableFooterView = footerView
        tableView.register(nibToken, forCellReuseIdentifier: "WalletCell")
        wallets.removeAll()
    }
    
    // MARK: - Table view updates
    
    func updateTable() {
        DispatchQueue.global().async { [weak self] in
            self?.getWallets()
        }
    }
    
    private func getWallets() {
        DispatchQueue.global().async { [unowned self] in
            let walletsArray = self.walletsCoordinator.getWallets()
            self.wallets = walletsArray
            self.reloadDataInTable()
            self.updateWalletsBalances { [unowned self] in
                self.reloadDataInTable()
            }
        }
    }
    
    func reloadDataInTable() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Balances
    
    func updateWalletsBalances(completion: @escaping () -> Void) {
        guard !wallets.isEmpty else {return}
        var indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.global().sync { [unowned self] in
            for wallet in wallets {
                let dollarsBalance = self.walletsCoordinator.getDollarsBalance(for: wallet.wallet)
                self.wallets[indexPath.row].balanceUSD = dollarsBalance
                
//                DispatchQueue.main.async {
//                    tableView.reloadRows(at: [indexPath], with: .none)
//                }
                indexPath.row += 1
            }
            completion()
        }
    }
    
    // MARK: - Actions
    
    func deleteWallet(in indexPath: IndexPath) {
        alerts.showAccessAlert(for: self, with: "Delete wallet \(wallets[indexPath.row].wallet.name)?") { [unowned self] (answer) in
            if answer {
                do {
                    try self.wallets[indexPath.row].wallet.delete()
                    if self.wallets.count == 1 {
                        self.goToOnboarding()
                    } else {
                        //                        DispatchQueue.main.async { [unowned self] in
                        //                            self.tableView.deleteRows(at: [indexPath], with: .left)
                        //                        }
                        self.wallets.remove(at: indexPath.row)
                        CurrentWallet.currentWallet = self.wallets.first?.wallet
                        self.updateTable()
                    }
                } catch let error {
                    self.alerts.showErrorAlert(for: self, error: error, completion: nil)
                }
            }
        }
    }
    
    func goToOnboarding() {
        CurrentWallet.currentWallet = nil
        CurrentToken.currentToken = nil
        let vc = OnboardingViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func showInfoActions(for wallet: TableWallet) {
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
        //        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Buttons actions
    
    @IBAction func addWallet(_ sender: BasicBlueButton) {
        let vc = AddWalletViewController()
        navigationController?.pushViewController(vc, animated: true)
        //present(vc, animated: true, completion: nil)
    }
}
