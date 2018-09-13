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

