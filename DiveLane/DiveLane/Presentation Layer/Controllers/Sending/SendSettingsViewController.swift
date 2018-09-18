//
//  SendSettingsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader
import web3swift
import struct BigInt.BigUInt

class SendSettingsViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addressFromLabel: UILabel!
    @IBOutlet weak var enterAddressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var addressFromView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    var walletName: String?
    var walletAddress: String?
    var tokenBalance: String?
    var isFromDeepLink: Bool = false
    var height = NSLayoutConstraint()
    var dropDownView = UIView() {
        willSet {
            dropDownView.removeFromSuperview()
        }
    }
    
    var amountInString: String?
    var destinationAddress: String?
    let localStorage = LocalDatabase()
    
    let animation = AnimationController()
    
    var screenState: AppState = .ETH {
        didSet {
            print(screenState)
        }
    }
    
    let tokenDropdownManager = TokenDropdownManager()
    let walletDropdownManager = WalletDropdownManager()
    
    convenience init(walletName: String,
                     tokenBalance: String,
                     walletAddress: String) {
        self.init()
        self.walletName = walletName
        self.tokenBalance = tokenBalance
        self.walletAddress = walletAddress
    }
    
    convenience init(tokenAddress: String?,
                     amount: BigUInt,
                     destinationAddress: String,
                     isFromDeepLink: Bool = true) {
        self.init()
        CurrentToken.currentToken?.address = tokenAddress ?? ""
        let decimals = Float(1000000000000000000)
        let amountFloat = Float(amount)
        let resultAmount = Float(amountFloat/decimals)
        self.amountInString = String(resultAmount)
        self.destinationAddress = destinationAddress
        let wallet = LocalDatabase().getWallet()
        self.walletName = wallet?.name
        self.walletAddress = wallet?.address
        self.isFromDeepLink = isFromDeepLink
        if tokenAddress != nil {
            Web3SwiftService().getERCBalance(for: tokenAddress!,
                                             address: KeysService().selectedWallet()?.address ?? "")
            { (result, error) in
                DispatchQueue.main.async { [weak self] in
                    self?.tokenBalance = result ?? ""
                }
            }
        } else {
            Web3SwiftService().getETHbalance() { (result, error) in
                DispatchQueue.main.async { [weak self] in
                    self?.tokenBalance = result ?? ""
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        self.hideKeyboardWhenTappedAround()
        addressFromLabel.text = "From: " + (localStorage.getWallet()?.address ?? "")
        addGestureRecognizer()
        closeButton.isHidden = true
        //balanceOnWalletLabel.text = "Balance of \(walletName ?? "") wallet: \(tokenBalance ?? "0")"
        tokenNameLabel.text = CurrentToken.currentToken?.symbol.uppercased()
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        enterAddressTextField.text = destinationAddress
        amountTextField.text = amountInString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Send"
    }
    
    @IBAction func didChangeState(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            screenState = .ETH
        } else {
            screenState = .Plasma
        }
    }
    
    func addGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFrom))
        addressFromLabel.addGestureRecognizer(tap)
        addressFromLabel.isUserInteractionEnabled = true
        let tokenTap = UITapGestureRecognizer(target: self, action: #selector(didTapToken))
        tokenNameLabel.addGestureRecognizer(tokenTap)
        tokenNameLabel.isUserInteractionEnabled = true
    }
    
    //MARK: - Dropdown
    @objc func didTapFrom() {
        dropDownView = createDropdownView(withManager: .Wallets)
        self.view.addSubview(dropDownView)
        stackView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.dropDownView.alpha = 1.0
        }, completion: nil)
    }
    
    @objc func didTapToken() {
        dropDownView = createDropdownView(withManager: .Tokens)
        self.view.addSubview(dropDownView)
        stackView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.dropDownView.alpha = 1.0
        }, completion: nil)
    }
    
    func createDropdownView(withManager manager: ManagerType) -> UIView {
        guard let sv = addressFromView.superview else { return UIView() }
        let frame = CGRect(x: sv.frame.origin.x, y: addressFromView.frame.origin.y + addressFromView.frame.height + sv.frame.origin.y, width:  addressFromView.frame.width, height: 150)
        dropDownView = UIView(frame: frame)
        switch manager {
        case .Tokens:
            guard let wallet = localStorage.getWallet() else { return UIView() }
            tokenDropdownManager.tokens = localStorage.getAllTokens(for: wallet)
        case .Wallets:
            walletDropdownManager.wallets = localStorage.getAllWallets()
        }
        let tableView = UITableView()
        tableView.separatorStyle = .none
        let cellToRegister = manager == .Wallets ? "WalletCellDropdown" : "TokenCellDropdown"
        let nib = UINib(nibName: cellToRegister, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellToRegister)
        tableView.delegate = manager == .Wallets ? walletDropdownManager : tokenDropdownManager
        tableView.dataSource = manager == .Wallets ? walletDropdownManager : tokenDropdownManager
        walletDropdownManager.delegate = self
        tokenDropdownManager.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        dropDownView.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: dropDownView.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: dropDownView.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: dropDownView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: dropDownView.bottomAnchor).isActive = true
        dropDownView.alpha = 0
        dropDownView.layer.cornerRadius = 5.0
        dropDownView.clipsToBounds = true
        return dropDownView
    }
    
    // MARK: QR Code scan
    lazy var readerVC: QRCodeReaderViewController = {
        
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showSwitchCameraButton = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    //    func sendFunds(dict: [String:Any], enteredPassword: String) {
    //        //let sendEthService: SendEthService = self.tokenService.selectedERC20Token().address.isEmpty ? SendEthServiceImplementation() : ERC20TokenContractMethodsServiceImplementation()
    //        let token  = CurrentToken.currentToken
    //        let model = ETHTransactionModel(from: dict["fromAddress"] as! String, to: dict["toAddress"] as! String, amount: dict["amount"] as! String, date: Date(), token: token!, key: KeysService().selectedKey()!, isPending: true)
    //        var options = Web3Options.defaultOptions()
    //        options.gasLimit = BigUInt(dict["gasLimit"] as! String)
    //        let gp = BigUInt(Double(dict["gasPrice"] as! String)! * pow(10, 9))
    //        options.gasPrice = gp
    //        let transaction = dict["transaction"] as! TransactionIntermediate
    //        options.from = transaction.options?.from
    //        options.to = transaction.options?.to
    //        options.value = transaction.options?.value
    //        TransactionsService().sendToken(transaction: transaction, with: enteredPassword, options: options) { [weak self] (result) in
    //            switch result {
    //            case .Success(let res):
    //                CurrentToken.currentToken = nil
    //                if (self?.isFromDeepLink)!{
    //                    showSuccessAlert(for: self!, completion: {
    //                        let startViewController = AppController().goToApp()
    //                        startViewController.view.backgroundColor = UIColor.white
    //                        UIApplication.shared.keyWindow?.rootViewController = startViewController
    //                    })
    //                } else {
    //                    showSuccessAlert(for: self!, completion: {
    //                        self?.navigationController?.popViewController(animated: true)
    //                    })
    //                }
    //
    //            case .Error(let error):
    //                var valueToSend = ""
    //                if let error = error as? Web3Error {
    //                    switch error {
    //                    case .nodeError(let text):
    //                        valueToSend = text
    //                    default:
    //                        break
    //                    }
    //                }
    //                print("\(error)")
    //                showErrorAlert(for: self!, error: error)
    //            }
    //        }
    //    }
    
    @IBAction func scanQR(_ sender: UIButton) {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    //    func enterPassword() {
    //        let alert = UIAlertController(title: "Send transaction", message: nil, preferredStyle: UIAlertControllerStyle.alert)
    //
    //        alert.addTextField { (textField) in
    //            textField.isSecureTextEntry = true
    //            textField.placeholder = "Enter your password"
    //        }
    //        let enterPasswordAction = UIAlertAction(title: "Enter", style: .default) { [weak self] (alertAction) in
    //            let passwordText = alert.textFields![0].text!
    //            if let privateKey = KeysService().getWalletPrivateKey(password: passwordText) {
    //
    //                self?.prepareTransation(withPassword: passwordText)
    //
    //            } else {
    //                showErrorAlert(for: self!, error: SendErrors.wrongPassword, completion: {
    //
    //                })
    //            }
    //        }
    //        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
    //
    //        }
    //
    //        alert.addAction(enterPasswordAction)
    //        alert.addAction(cancelAction)
    //
    //        self.present(alert, animated: true, completion: nil)
    //    }
    
    func prepareTransation(withPassword: String?) {
        
        guard let amount = amountTextField.text,
            let destinationAddress = enterAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
        }
        
        if CurrentToken.currentToken?.address == "" {
            TransactionsService().prepareTransactionForSendingEther(destinationAddressString: destinationAddress, amountString: amount, gasLimit: 21000) { [weak self] (result) in
                switch result {
                case .Success(let transaction):
                    guard let gasPrice = self?.gasPriceTextField.text else { return }
                    guard let gasLimit = self?.gasLimitTextField.text else { return }
                    guard let name = self?.walletName else { return }
                    let dict:[String:Any] = [
                        "gasPrice":gasPrice,
                        "gasLimit":gasLimit,
                        "transaction":transaction,
                        "amount": amount,
                        "name": name,
                        "fromAddress": self!.walletAddress!,
                        "toAddress": destinationAddress]
                    
                    showAccessAlert(for: self!, with: "Send the transaction?", completion: { (result) in
                        if result {
                            self?.enterPincode(for: dict, withPassword: withPassword)
                        } else {
                            showErrorAlert(for: self!, error: TransactionErrors.PreparingError, completion: {
                                
                            })
                        }
                    })
                    //self?.sendFunds(dict: dict, enteredPassword: withPassword)
                    
                case .Error(let error):
                    var textToSend = ""
                    if let error = error as? SendErrors {
                        switch error {
                        case .invalidDestinationAddress:
                            textToSend = "invalidAddress"
                        default:
                            break
                        }
                    }
                    
                    showErrorAlert(for: self!, error: error, completion: {
                        
                    })
                }
            }
        } else {
            TransactionsService().prepareTransactionForSendingERC(destinationAddressString: destinationAddress, amountString: amount, gasLimit: 21000, tokenAddress: (CurrentToken.currentToken?.address)!) { [weak self] (result) in
                switch result {
                case .Success(let transaction):
                    guard let gasPrice = self?.gasPriceTextField.text else { return }
                    guard let gasLimit = self?.gasLimitTextField.text else { return }
                    guard let name = self?.walletName else { return }
                    let dict:[String:Any] = [
                        "gasPrice":gasPrice,
                        "gasLimit":gasLimit,
                        "transaction":transaction,
                        "amount":amount,
                        "name": name,
                        "fromAddress": self!.walletAddress!,
                        "toAddress": destinationAddress]
                    
                    //self?.sendFunds(dict: dict, enteredPassword: withPassword)
                    showAccessAlert(for: self!, with: "Send the transaction?", completion: { (result) in
                        if result {
                            self?.enterPincode(for: dict, withPassword: withPassword)
                        } else {
                            showErrorAlert(for: self!, error: TransactionErrors.PreparingError, completion: {
                                
                            })
                        }
                        
                    })
                case .Error(let error):
                    var textToSend = ""
                    if let error = error as? SendErrors {
                        switch error {
                        case .invalidDestinationAddress:
                            textToSend = "invalidAddress"
                        default:
                            break
                        }
                    }
                    
                    showErrorAlert(for: self!, error: error, completion: {
                        
                    })
                }
            }
        }
    }
    
    @IBAction func send(_ sender: UIButton) {
        //enterPassword()
        //enterPincode()
        checkPassword { [weak self] (password) in
            self?.prepareTransation(withPassword: password)
        }
    }
    
    func checkPassword(completion: @escaping (String?) -> Void) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                    account: "\(self.walletName ?? "")-password",
                accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            completion(keychainPassword)
        } catch {
            //            fatalError("Error reading password from keychain - \(error)")
            completion(nil)
        }
    }
    
    func enterPincode(for data: [String:Any]?, withPassword: String?) {
        guard let data = data else {
            showErrorAlert(for: self, error: TransactionErrors.PreparingError, completion: {
                
            })
            return
        }
        let enterPincode = EnterPincodeViewController(from: .transaction, for: data, withPassword: withPassword ?? "", isFromDeepLink: isFromDeepLink)
        self.navigationController?.pushViewController(enterPincode, animated: true)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        let startViewController = AppController().goToApp()
        startViewController.view.backgroundColor = UIColor.white
        UIApplication.shared.keyWindow?.rootViewController = startViewController
    }
}

//MARK: - Dropdowns Delegates
extension SendSettingsViewController: WalletSelectionDelegate, TokenSelectionDelegate {
    func didSelectWallet(wallet: KeyWalletModel) {
        localStorage.selectWallet(wallet: wallet) {
            self.addressFromLabel.text = "From: " + wallet.address
            UIView.animate(withDuration: 0.5, animations: {
                self.dropDownView.alpha = 0.0
            }, completion: { (_) in
                self.stackView.isUserInteractionEnabled = true
                self.dropDownView.removeFromSuperview()
            })
        }
    }
    
    func didSelectToken(token: ERC20TokenModel) {
        self.tokenNameLabel.text = token.symbol.uppercased()
        CurrentToken.currentToken = token
        UIView.animate(withDuration: 0.5, animations: {
            self.dropDownView.alpha = 0.0
        }) { (_) in
            self.stackView.isUserInteractionEnabled = true
            self.dropDownView.removeFromSuperview()
        }
    }

}

// MARK: - QRCodeReaderViewController Delegate Methods
extension SendSettingsViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let value = result.value
        
        if let parsed = Web3.EIP67CodeParser.parse(value) {
            enterAddressTextField.text = parsed.address.address
            if let amount = parsed.amount {
                if CurrentToken.currentToken != ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth") {
                    CurrentToken.currentToken = ERC20TokenModel(name: "", address: "", decimals: "", symbol: "")
                }
                amountTextField.text = Web3.Utils.formatToEthereumUnits(
                    amount,
                    toUnits: .eth,
                    decimals: 4)
            }
        }
        else  {
            if let _ = EthereumAddress(value) {
                enterAddressTextField.text = value
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: TextField Delegate
extension SendSettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = sendButton.isEnabled ? UIReturnKeyType.done : .next
        textField.textColor = UIColor.black
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        sendButton.isEnabled = false
        
        switch textField {
        case enterAddressTextField:
            if  !futureString.isEmpty && !(amountTextField.text?.isEmpty ?? true) && !(gasLimitTextField.text?.isEmpty ?? true) && !(gasPriceTextField.text?.isEmpty ?? true) {
                sendButton.isEnabled = (Float((amountTextField.text ?? "")) != nil)
            }
        case amountTextField:
            if !futureString.isEmpty && !(enterAddressTextField.text?.isEmpty ?? true) && !(gasLimitTextField.text?.isEmpty ?? true) && !(gasPriceTextField.text?.isEmpty ?? true)
            {
                sendButton.isEnabled =  (Float((futureString)) != nil)
            }
        case gasPriceTextField:
            if !futureString.isEmpty && !(amountTextField.text?.isEmpty ?? true) && !(enterAddressTextField.text?.isEmpty ?? true) && !(gasLimitTextField.text?.isEmpty ?? true) {
                sendButton.isEnabled = true
            }
        case gasLimitTextField:
            if !futureString.isEmpty && !(amountTextField.text?.isEmpty ?? true) && !(enterAddressTextField.text?.isEmpty ?? true) && !(gasPriceTextField.text?.isEmpty ?? true) {
                sendButton.isEnabled = true
            }
        default:
            sendButton.isEnabled = false
        }
        
        sendButton.alpha = sendButton.isEnabled ? 1.0 : 0.5
        textField.returnKeyType = sendButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && sendButton.isEnabled {
            checkPassword { [weak self] (password) in
                self?.prepareTransation(withPassword: password)
            }
        } else if textField.returnKeyType == .next {
            let index = textFields.index(of: textField) ?? 0
            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
            textFields[nextIndex].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        textField.textColor = UIColor.darkText
        
        if textField == amountTextField {
            guard let _ = Float((amountTextField.text ?? "")) else {
                amountTextField.textColor = UIColor.red
                return true
            }
        }
        if textField == gasLimitTextField {
            guard let _ = Int((gasLimitTextField.text ?? "")) else {
                gasLimitTextField.textColor = UIColor.red
                return true
            }
            if Int((gasLimitTextField.text ?? "0"))! > 21000 {
                gasLimitTextField.text = "21000"
            }
            if Int((gasLimitTextField.text ?? "0"))! < 5 {
                gasLimitTextField.text = "5"
            }
        }
        if textField == gasPriceTextField {
            guard let _ = Int((gasPriceTextField.text ?? "")) else {
                gasPriceTextField.textColor = UIColor.red
                return true
            }
            if Int((gasPriceTextField.text ?? "0"))! > 100 {
                gasPriceTextField.text = "100"
            }
            if Int((gasPriceTextField.text ?? "0"))! < 5 {
                gasPriceTextField.text = "5"
            }
        }
        return true
    }
}
