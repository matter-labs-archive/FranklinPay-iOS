//
//  AddWalletViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AddWalletViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = Colors.NavBarColors.mainTint
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .black
    }

    let isNavigationBarNeeded: Bool


    init(isNavigationBarNeeded: Bool = false) {
        self.isNavigationBarNeeded = isNavigationBarNeeded
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = !isNavigationBarNeeded
    }

    @IBAction func importWallet(_ sender: UIButton) {
        showChooseImportTypeAlert()
    }

    @IBAction func createWallet(_ sender: UIButton) {
        goToWalletCreation(type: .createWallet, importType: nil)
    }

    func goToWalletCreation(type: WalletAdditionMode, importType: WalletImportMode?) {
        let walletCreationViewController = WalletCreationViewController(additionType: type, importType: importType)
        self.navigationController?.pushViewController(walletCreationViewController, animated: true)
    }

    func showChooseImportTypeAlert() {
        let alertController = UIAlertController(title: "Wallet import type", message: "How would you like to import ypur wallet?", preferredStyle: .alert)
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { (_) in
            self.goToWalletCreation(type: .importWallet, importType: .mnemonics)
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { (_) in
            self.goToWalletCreation(type: .importWallet, importType: .privateKey)
        }
        alertController.addAction(mnemonicsAction)
        alertController.addAction(privateKeyAction)
        self.present(alertController, animated: true) {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }

    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }

}

