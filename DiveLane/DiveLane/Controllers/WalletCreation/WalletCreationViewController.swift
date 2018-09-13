//
//  WalletCreationViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader
import web3swift

class WalletCreationViewController: UIViewController {
    
    @IBOutlet weak var passwordsDontMatch: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var enterPrivateKeyTextField: UITextField!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var walletNameTextField: UITextField!
    
    var additionMode: WalletAdditionMode
    var importMode: WalletImportMode?
    
    let keysService: KeysService = KeysService()
    let localStorage = LocalDatabase()
    let web3service: Web3SwiftService = Web3SwiftService()
    
    let animation = AnimationController()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    init(additionType: WalletAdditionMode, importType: WalletImportMode?) {
        additionMode = additionType
        importMode = importType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch importMode {
        case .mnemonics?:
            enterPrivateKeyTextField.placeholder = "Enter mnemonics"
            qrCodeButton.isHidden = true
        case .privateKey?:
            enterPrivateKeyTextField.placeholder = "Enter Private Key"
        default:
            print("Creation")
        }
        self.title = additionMode.title()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.hideKeyboardWhenTappedAround()
        enterButton.setTitle(additionMode.title(), for: .normal)
        enterButton.isEnabled = false
        enterButton.alpha = 0.5
        passwordsDontMatch.alpha = 0
        passwordTextField.isHidden = UserDefaults.standard.bool(forKey: "atLeastOneWalletExists")
        repeatPasswordTextField.isHidden = UserDefaults.standard.bool(forKey: "atLeastOneWalletExists")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = additionMode.title()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if additionMode == .createWallet {
            enterPrivateKeyTextField.isHidden = true
            qrCodeButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @IBAction func qrScanTapped(_ sender: Any) {
        readerVC.delegate = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    func addPincode(toWallet: KeyWalletModel?, with password: String) {
        guard let wallet = toWallet else {
            showErrorAlert(for: self, error: WalletSavingError.couldNotCreateTheWallet, completion: {
                
            })
            return
        }
        let addPincode = CreateWalletPincodeViewController(forWallet: wallet, with: password)
        self.navigationController?.pushViewController(addPincode, animated: true)
        
    }
    
    func checkExistingPassword() -> String {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                   account: "password",
                                                   accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return keychainPassword
        } catch {
//            fatalError("Error reading password from keychain - \(error)")
            return passwordTextField.text ?? ""
        }
    }
    
    func createPassword() {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                   account: "password",
                                                   accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(passwordTextField.text ?? "")
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    @IBAction func addWalletButtonTapped(_ sender: Any) {
        guard passwordTextField.text == repeatPasswordTextField.text else {
            passwordsDontMatch.alpha = 1
            return
        }
        passwordsDontMatch.alpha = 0
        
        let isAtLeastOneWalletExists = UserDefaults.standard.bool(forKey: "atLeastOneWalletExists")
        let password = isAtLeastOneWalletExists ? checkExistingPassword() : (passwordTextField.text ?? "")
        
        DispatchQueue.main.async { [weak self] in
            self?.animation.waitAnimation(isEnabled: true,
                                          notificationText: "Creating wallet",
                                          on: (self?.view)!)
        }
        switch additionMode {
        case .createWallet:
            //Create new wallet
//            keysService.createNewWallet(withName: self.walletNameTextField.text,
//                                        password: password)
//            { [weak self] (wallet, error) in
//                DispatchQueue.main.async {
//                    self?.animation.waitAnimation(isEnabled: false,
//                                                  on: (self?.view)!)
//                }
//                if let error = error {
//                    showErrorAlert(for: self!, error: error, completion: {
//
//                    })
//                } else {
//
//                    switch isAtLeastOneWalletExists {
//                    case true:
//                        self?.savingWallet(wallet: wallet)
//                    case false:
//                        self?.addPincode(toWallet: wallet, with: password)
//                    }
//                }
//            }
            showChooseAlert(withPassword: password)
            
        default:
            //Import wallet
            guard let importMode = importMode else { return }
            
            switch importMode {
            case .mnemonics:
                keysService.createNewHDWallet(withName: walletNameTextField.text!, password: enterPrivateKeyTextField.text!, mnemonics: enterPrivateKeyTextField.text!) { [weak self] (keyWalletModel, error) in
                    DispatchQueue.main.async {
                        self?.animation.waitAnimation(isEnabled: false,
                                                      on: (self?.view)!)
                    }
                    if let error = error {
                        print(error)
                    } else {
                        switch isAtLeastOneWalletExists {
                        case true:
                            self?.savingWallet(wallet: keyWalletModel)
                        case false:
                            self?.addPincode(toWallet: keyWalletModel, with: password)
                        }
                    }
                }
            case .privateKey:
                keysService.addNewWalletWithPrivateKey(withName: self.walletNameTextField.text,
                                                       key: enterPrivateKeyTextField.text!,
                                                       password: passwordTextField.text!) 
                { [weak self] (wallet, error) in
                    DispatchQueue.main.async {
                        self?.animation.waitAnimation(isEnabled: false,
                                                  on: (self?.view)!)
                    } 
                    if let error = error {
                        showErrorAlert(for: self!, error: error, completion: {
                        
                        })
                        return
                    } else {
                        guard let walletStrAddress = wallet?.address, let _ = EthereumAddress(walletStrAddress) else {
                            showErrorAlert(for: self!, error: error, completion: {

                            })
                            return
                        }

                        switch isAtLeastOneWalletExists {
                        case true:
                            self?.savingWallet(wallet: wallet)
                        case false:
                            self?.addPincode(toWallet: wallet, with: password)
                        }
                    }
                }
            }  
        }
    }
    
    
    func savingWallet(wallet: KeyWalletModel?) {
        DispatchQueue.main.async { [weak self] in
            self?.animation.waitAnimation(isEnabled: true,
                                          notificationText: "Saving wallet",
                                          on: (self?.view)!)
        }
        self.localStorage.saveWallet(wallet: wallet) { [weak self] (error) in
            if error == nil {
                self?.createPassword()
                DispatchQueue.main.async { [weak self] in
                    self?.animation.waitAnimation(isEnabled: false,
                                                  on: (self?.view)!)
                }
                self?.localStorage.selectWallet(wallet: wallet, completion: {
                    let tabViewController = AppController().goToApp()
                    tabViewController.view.backgroundColor = UIColor.white
                    self?.present(tabViewController, animated: true, completion: nil)
                })
            } else {
                showErrorAlert(for: self!, error: error, completion: {
                    
                })
            }
        }
    }
    
    func showChooseAlert(withPassword: String) {
        let isAtLeastOneWalletExists = UserDefaults.standard.bool(forKey: "atLeastOneWalletExists")
        let alertController = UIAlertController(title: "Wallet type", message: "How would you like to create your wallet?", preferredStyle: .alert)
        let actionMnemonics = UIAlertAction(title: "Mnemonics", style: .default) { [weak self] (_) in
            let mnemonicsViewController = MnemonicsViewController(name: (self?.walletNameTextField.text!)!, password: withPassword)
            self?.navigationController?.pushViewController(mnemonicsViewController, animated: true)
        }
        
        let actionPrivateKey = UIAlertAction(title: "Private Key", style: .default) { [weak self] _ in
            self?.keysService.createNewWallet(withName: self?.walletNameTextField.text,
                                        password: withPassword)
            { [weak self] (wallet, error) in
                DispatchQueue.main.async {
                    self?.animation.waitAnimation(isEnabled: false,
                                                  on: (self?.view)!)
                }
                if let error = error {
                    showErrorAlert(for: self!, error: error, completion: {
                        
                    })
                } else {
                    
                    switch isAtLeastOneWalletExists {
                    case true:
                        self?.savingWallet(wallet: wallet)
                    case false:
                        self?.addPincode(toWallet: wallet, with: withPassword)
                    }
                }
            }
        }
        alertController.addAction(actionMnemonics)
        alertController.addAction(actionPrivateKey)
        self.present(alertController, animated: true) {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension WalletCreationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = enterButton.isEnabled ? UIReturnKeyType.done : .next
        textField.textColor = UIColor.blue
        if textField == passwordTextField || textField == repeatPasswordTextField {
            passwordsDontMatch.alpha = 0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        enterButton.isEnabled = false
        
        switch textField {
        case enterPrivateKeyTextField:
            if UserDefaults.standard.bool(forKey: "atLeastOneWalletExists") {
                if !(walletNameTextField.text?.isEmpty ?? true) &&
                    !futureString.isEmpty {
                    enterButton.isEnabled = true
                } else {
                    enterButton.isEnabled = false
                }
            } else {
                if passwordTextField.text == repeatPasswordTextField.text &&
                    !(passwordTextField.text?.isEmpty ?? true) &&
                    !futureString.isEmpty && !(walletNameTextField.text?.isEmpty ?? true) {
                    enterButton.isEnabled = true
                } else {
                    enterButton.isEnabled = false
                }
            }
        case passwordTextField:
            if !futureString.isEmpty &&
                futureString == repeatPasswordTextField.text {
                passwordsDontMatch.alpha = 0
                enterButton.isEnabled = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || additionMode == .createWallet)
            } else {
                passwordsDontMatch.alpha = 1
                enterButton.isEnabled = false
            }
        case repeatPasswordTextField:
            if !futureString.isEmpty &&
                futureString == passwordTextField.text {
                passwordsDontMatch.alpha = 0
                enterButton.isEnabled = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || additionMode == .createWallet)
            } else {
                passwordsDontMatch.alpha = 1
                enterButton.isEnabled = false
            }
        default:
            if UserDefaults.standard.bool(forKey: "atLeastOneWalletExists") {
                if additionMode == .importWallet {
                    if !futureString.isEmpty && !(enterPrivateKeyTextField.text?.isEmpty ?? true) {
                        enterButton.isEnabled = true
                    } else {
                        enterButton.isEnabled = false
                    }
                } else if !futureString.isEmpty {
                    enterButton.isEnabled = true
                } else {
                    enterButton.isEnabled = false
                }
                
            } else {
                if additionMode == .importWallet {
                    if !futureString.isEmpty && passwordTextField.text == repeatPasswordTextField.text &&
                        !(passwordTextField.text?.isEmpty ?? true) &&
                        !(enterPrivateKeyTextField.text?.isEmpty ?? true) {
                        enterButton.isEnabled = true
                    } else {
                        enterButton.isEnabled = false
                    }
                } else if !futureString.isEmpty {
                    enterButton.isEnabled = true
                } else {
                    enterButton.isEnabled = false
                }
                
            }
            
        }
        
        enterButton.alpha = enterButton.isEnabled ? 1.0 : 0.5
        textField.returnKeyType = enterButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.textColor = UIColor.darkGray
        
        guard textField == repeatPasswordTextField ||
            textField == passwordTextField else {
                return true
        }
        if (!(passwordTextField.text?.isEmpty ?? true) ||
            !(repeatPasswordTextField.text?.isEmpty ?? true)) &&
            passwordTextField.text != repeatPasswordTextField.text {
            passwordsDontMatch.alpha = 1
            repeatPasswordTextField.textColor = UIColor.red
            passwordTextField.textColor = UIColor.red
        } else {
            repeatPasswordTextField.textColor = UIColor.darkGray
            passwordTextField.textColor = UIColor.darkGray
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && enterButton.isEnabled {
            addWalletButtonTapped(self)
        } else if textField.returnKeyType == .next {
            let index = textFields.index(of: textField) ?? 0
            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
            textFields[nextIndex].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}


extension WalletCreationViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        enterPrivateKeyTextField.text = result.value
        if passwordTextField.text == repeatPasswordTextField.text &&
            !(passwordTextField.text?.isEmpty ?? true) {
            enterButton.isEnabled = true
            enterButton.alpha = 1
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
}

