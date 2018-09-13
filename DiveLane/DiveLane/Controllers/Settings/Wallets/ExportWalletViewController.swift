//
//  ExportWalletViewController.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class ExportWalletViewController: UIViewController {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    let walletModel: KeyWalletModel
    let keysService: IKeysService
    init(model: KeyWalletModel) {
        self.walletModel = model
        self.keysService = KeysService()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("required init?(coder aDecoder: NSCoder) is not implemented!")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        walletNameLabel.text = "Name: " + walletModel.name
        walletAddressLabel.text = "Address: " + walletModel.address
        navigationItem.title = "Wallet"
        
    }
    
    @IBAction func exportPrivateKeyButtonTapped(_ sender: Any) {
        enterPassword()
    }
    
    func enterPassword() {
        let alert = UIAlertController(title: "Show private key", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter your password"
        }
        
        let enterPasswordAction = UIAlertAction(title: "Enter", style: .default) { (alertAction) in
            let passwordText = alert.textFields![0].text!
            if let _ = KeysService().getWalletPrivateKey(password: passwordText) {
                self.showPK(withPassword: passwordText)
                
            } else {
                //showErrorAlert(for: self, error: SendErrors.wrongPassword,
                showErrorAlert(for: self, error: SendErrors.wrongPassword, completion: {
                    
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            
        }
        
        alert.addAction(enterPasswordAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPK(withPassword password: String) {
        guard let pk = keysService.getPrivateKey(forWallet: walletModel, password: password) else { return }
        let privateKeyViewController = PrivateKeyViewController(pk: pk)
        self.navigationController?.pushViewController(privateKeyViewController, animated: true)
    }
    
}
