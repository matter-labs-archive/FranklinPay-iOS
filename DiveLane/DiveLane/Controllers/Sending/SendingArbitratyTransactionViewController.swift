//
//  SendingArbitratyTransactionViewController.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class SendArbitraryTransactionViewController: UIViewController {
    
    @IBOutlet weak var balanceOnWalletTextField: UILabel!
    @IBOutlet weak var fromTextField: UILabel!
    @IBOutlet weak var contractAddressTextField: UITextField!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var methodNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var params: [Parameter]
    var transactionInfo: TransactionInfo
    
    init(params: [Parameter], transactionInfo: TransactionInfo) {
        self.params = params
        self.transactionInfo = transactionInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        let nib = UINib.init(nibName: "ParameterCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ParameterCell")
        
        self.title = "Transaction"
        //TODO: - Setup outlets
        methodNameLabel.text = "Method name: " + transactionInfo.methodName
        if let address = KeysService().selectedWallet()?.address {
            fromTextField.text = "From: \(address)"
        }
        
        Web3SwiftService().getETHbalance { (balance, error) in
            if let balance = balance {
                self.balanceOnWalletTextField.text = "Wallet balance: " + balance + " ETH"
            }
        }
        contractAddressTextField.text = transactionInfo.contractAddress
        gasPriceTextField.text = transactionInfo.transactionIntermediate.transaction.gasPrice.description
        gasLimitTextField.text = transactionInfo.transactionIntermediate.transaction.gasLimit.description
    }
    
    
    @IBAction func sendButtonWasTapped(_ sender: Any) {
        //TODO: - Password
        enterPassword()
        
    }
    
    @IBAction func closeButtonWasTapped(_ sender: Any) {
        let c = self.goToApp()
        c.view.backgroundColor = UIColor.white
        UIApplication.shared.keyWindow?.rootViewController = c
    }
    
    func enterPassword() {
        let alert = UIAlertController(title: "Send transaction", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter your password"
        }
        let enterPasswordAction = UIAlertAction(title: "Enter", style: .default) { (alertAction) in
            let passwordText = alert.textFields![0].text!
            if let privateKey = KeysService().getWalletPrivateKey(password: passwordText) {
                
                self.send(withPassword: passwordText)
                
            } else {
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
    
    func send(withPassword password: String) {
        guard let destinationAddress = contractAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return }
        TransactionsService().sendToContract(transaction: transactionInfo.transactionIntermediate, with: password) { (result) in
            switch result {
            case .Error(let error):
                print(error)
            case .Success(let success):
                print(success)
                showSuccessAlert(for: self, completion: {
                    let c = self.goToApp()
                    c.view.backgroundColor = UIColor.white
                    UIApplication.shared.keyWindow?.rootViewController = c
                })
            }
        }
        
    }
    
    func goToApp() -> UITabBarController {
        
        var nav1 = UINavigationController()
        var first = WalletViewController(nibName: nil, bundle: nil)
        nav1.viewControllers = [first]
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(named:"user"), tag: 1)
        
        var nav2 = UINavigationController()
        var second = SettingsViewController(nibName: nil, bundle: nil)
        nav2.viewControllers = [second]
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(named:"settings"), tag: 2)
        
        var tabs = UITabBarController()
        tabs.viewControllers = [nav1, nav2]
        
        return tabs
    }
    
}

extension SendArbitraryTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return params.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell", for: indexPath) as? ParameterCell else { return UITableViewCell() }
        cell.configure(params[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
