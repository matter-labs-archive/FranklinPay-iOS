//
//  WalletsViewController.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class WalletsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let localDatabase = WalletsStorage()
    let keysService = WalletsService()
    var wallets: [WalletModel] = []

//    init() {
//        do {
//            let wallets = try localDatabase.getAllWallets()
//            self.wallets = wallets
//        } catch let error {
//            self.wallets = []
//            print(error)
//        }
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallets"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        getWallets()
    }
    
    private func getWallets() {
        do {
            let wallets = try self.localDatabase.getAllWallets()
            self.wallets = wallets
            self.tableView.reloadData()
        } catch {
            self.wallets = []
            self.tableView.reloadData()
            self.getWallets()
        }
        let nib = UINib(nibName: "WalletCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "WalletCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc func addButtonTapped() {
        let addWalletViewController = AddWalletViewController(isNavigationBarNeeded: true)
        self.navigationController?.pushViewController(addWalletViewController, animated: true)
    }

    func showAttentionAlert(wallet: WalletModel, indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Attention!", message: "Are you sure that you want to delete wallet \"\(wallet.name)\"?", preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] (_) in
            DispatchQueue.global().async {
                do {
                    try self?.localDatabase.deleteWallet(wallet: wallet)
                    self?.wallets.remove(at: indexPath.row)
                    if self?.wallets.first == nil {
                        UserDefaults.standard.set(false, forKey: "atLeastOneWalletExists")
                        UserDefaults.standard.set(false, forKey: "pincodeExists")
                        DispatchQueue.main.async {
                            let nav = UINavigationController()
                            nav.viewControllers = [AddWalletViewController()]
                            UIApplication.shared.keyWindow?.rootViewController = nav
                        }
                    } else {
                        try self?.localDatabase.selectWallet(wallet: (self?.wallets.first)!)
                        DispatchQueue.main.async {
                            self?.tableView.deleteRows(at: [indexPath], with: .left)
                        }
                    }
                } catch let error {
                    Alerts().showErrorAlert(for: self!, error: error, completion: {})
                }
            }
        }
        let declaneAction = UIAlertAction(title: "No", style: .default) { (_) in
        }
        alertController.addAction(acceptAction)
        alertController.addAction(declaneAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

extension WalletsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell else {
            return UITableViewCell()
        }
        cell.configureCell(model: wallets[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.localDatabase.selectWallet(wallet: wallets[indexPath.row]) {
//            tableView.deselectRow(at: indexPath, animated: true)
//            self.navigationController?.popViewController(animated: true)
//        }
        tableView.deselectRow(at: indexPath, animated: true)
        let wallet = wallets[indexPath.row]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let exportAction = UIAlertAction(title: "Export private key", style: .destructive) { [weak self] (_) in
            self?.enterPassword(for: wallet)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        alertController.addAction(exportAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func enterPassword(for wallet: WalletModel) {
        let alert = UIAlertController(title: "Show private key", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter your password"
        }

        let enterPasswordAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let passwordText = alert.textFields![0].text!
            do {
                _ = try WalletsService().getPrivateKey(for: wallet, password: passwordText)
                self.showPK(for: wallet, withPassword: passwordText)
            } catch let error {
                Alerts().showErrorAlert(for: self, error: error, completion: {
                    
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in

        }

        alert.addAction(enterPasswordAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    func showPK(for wallet: WalletModel, withPassword password: String) {
        guard let pk = try? keysService.getPrivateKey(for: wallet, password: password) else {
            return
        }
        let privateKeyViewController = PrivateKeyViewController(pk: pk)
        self.navigationController?.pushViewController(privateKeyViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showAttentionAlert(wallet: wallets[indexPath.row], indexPath: indexPath)
        }
    }
}
