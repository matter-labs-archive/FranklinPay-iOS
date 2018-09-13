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
        
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 13/255, green: 92/255, blue: 182/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func importWallet(_ sender: UIButton) {
        goToWalletCreation(type: .importWallet)
    }
    
    @IBAction func createWallet(_ sender: UIButton) {
        goToWalletCreation(type: .createWallet)
    }
    
    func goToWalletCreation(type: WalletAdditionMode) {
        let walletCreationViewController = WalletCreationViewController(additionType: type)
        self.navigationController?.pushViewController(walletCreationViewController, animated: true)
    }
    
}

