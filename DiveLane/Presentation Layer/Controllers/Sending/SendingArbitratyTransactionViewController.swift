//
//  SendingArbitratyTransactionViewController.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

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
        CurrentToken.currentToken = ERC20TokenModel(isEther: true)
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
        // MARK: Setup outlets
        methodNameLabel.text = "Method name: " + transactionInfo.methodName
        if let address = KeysService().selectedWallet()?.address {
            fromTextField.text = "From: \(address)"
        }

        guard let wallet = LocalDatabase().getWallet() else {
            return
        }

        Web3SwiftService().getETHbalance(for: wallet) { (balance, _) in
            if let balance = balance {
                self.balanceOnWalletTextField.text = "Wallet balance: " + balance + " ETH"
            }
        }
        contractAddressTextField.text = transactionInfo.contractAddress
        gasPriceTextField.text = transactionInfo.transactionIntermediate.transaction.gasPrice.description
        gasLimitTextField.text = transactionInfo.transactionIntermediate.transaction.gasLimit.description
    }

    @IBAction func sendButtonWasTapped(_ sender: Any) {
        // MARK: Password
        enterPassword()

    }

    @IBAction func closeButtonWasTapped(_ sender: Any) {
        let c = self.goToApp()
        c.view.backgroundColor = UIColor.white
        UIApplication.shared.keyWindow?.rootViewController = c
    }

    func enterPassword() {
        let alert = UIAlertController(title: "Send transaction", message: nil, preferredStyle: UIAlertController.Style.alert)

        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter your password"
        }
        let enterPasswordAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let passwordText = alert.textFields![0].text!
            if KeysService().getWalletPrivateKey(for: KeysService().selectedWallet()!, password: passwordText) != nil {

                self.send(withPassword: passwordText)

            } else {
                showErrorAlert(for: self, error: SendErrors.wrongPassword, completion: {

                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in

        }

        alert.addAction(enterPasswordAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    func send(withPassword password: String) {
        guard (contractAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) != nil else {
            return
        }
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

        let nav1 = UINavigationController()
        let first = WalletViewController(nibName: nil, bundle: nil)
        nav1.viewControllers = [first]
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "wallet"), tag: 1)

        let nav2 = UINavigationController()
        let second = SettingsViewController(nibName: nil, bundle: nil)
        nav2.viewControllers = [second]
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "settings"), tag: 2)

        let tabs = UITabBarController()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell", for: indexPath) as? ParameterCell else {
            return UITableViewCell()
        }
        cell.configure(params[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

}
