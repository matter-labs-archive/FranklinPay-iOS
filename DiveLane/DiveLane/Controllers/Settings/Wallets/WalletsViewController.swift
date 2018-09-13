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
    
    let localDatabase: ILocalDatabase
    let keysService: IKeysService
    var wallets: [KeyWalletModel]

    init() {
        localDatabase = LocalDatabase()
        wallets = localDatabase.getAllWallets()
        keysService = KeysService()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallets"
        let nib = UINib(nibName: "WalletCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "WalletCell")
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    @objc func addButtonTapped() {
        let addWalletViewController = AddWalletViewController(isNavigationBarNeeded: true)
        self.navigationController?.pushViewController(addWalletViewController, animated: true)
    }
    
    func showAttentionAlert(wallet: KeyWalletModel, indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Attention!", message: "Are you sure that you want to delete wallet \"\(wallet.name)\"?", preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "Yes", style: .destructive) { (_) in
            self.localDatabase.deleteWallet(wallet: wallet) { (error) in
                if error == nil {
                    self.wallets.remove(at: indexPath.row)
                    if self.wallets.first == nil {
                        let nav = UINavigationController()
                        nav.viewControllers = [AddWalletViewController()]
                        UIApplication.shared.keyWindow?.rootViewController = nav
                    } else {
                        self.localDatabase.selectWallet(wallet: self.wallets.first, completion: {
                            self.tableView.deleteRows(at: [indexPath], with: .left)
                        })
                    }
                }
            }
        }
        let declaneAction = UIAlertAction(title: "No", style: .default) { (_) in }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell else { return UITableViewCell() }
        
        cell.configureCell(model: wallets[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.localDatabase.selectWallet(wallet: wallets[indexPath.row]) {
            let exportWalletViewController = ExportWalletViewController(model: self.wallets[indexPath.row])
            self.navigationController?.pushViewController(exportWalletViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showAttentionAlert(wallet: wallets[indexPath.row], indexPath: indexPath)
        }
    }
}
