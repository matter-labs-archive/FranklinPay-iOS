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
        updateEnterButtonAlpha()
        hidePasswordWarning(true)
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
    
    func checkExistingPassword(completion: @escaping (String?) -> Void) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                    account: "password",
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            completion(keychainPassword)
        } catch {
            //            fatalError("Error reading password from keychain - \(error)")
            completion(passwordTextField.text ?? "")
        }
    }
    
    func createPassword(_ password: String, forWallet: KeyWalletModel?) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                    account: "\(forWallet?.name ?? "")-password",
                accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    @IBAction func addWalletButtonTapped(_ sender: Any) {
        guard passwordTextField.text == repeatPasswordTextField.text else {
            hidePasswordWarning(false)
            return
        }
        hidePasswordWarning(true)
        
        guard let walletKey = enterPrivateKeyTextField.text else {
            return
        }
        
        let isAtLeastOneWalletExists = UserDefaults.standard.bool(forKey: "atLeastOneWalletExists")
        let password = passwordTextField.text ?? ""
        let walletName = walletNameTextField.text ?? ""
        self.addWalletDependingOnMode(walletName, withKey: walletKey, withPassword: password, isAtLeastOneExists: isAtLeastOneWalletExists)
        
    }

    private func hidePasswordWarning(_ hidden: Bool = true) {
        passwordsDontMatch.alpha = hidden ? 0 : 1

    }

    private func updateEnterButtonAlpha() {
        enterButton.alpha = enterButton.isEnabled ? 1.0 : 0.5
    }

    private func isEnterButtonEnabled(afterChanging textField: UITextField, with string: String) {

        enterButton.isEnabled = false

        switch textField {
        case enterPrivateKeyTextField:
            let everyFieldIsOK = passwordTextField.text == repeatPasswordTextField.text &&
                !(passwordTextField.text?.isEmpty ?? true) &&
                !string.isEmpty && !(walletNameTextField.text?.isEmpty ?? true)
            enterButton.isEnabled = everyFieldIsOK
        case passwordTextField:
            let repeatPasswordIsEmpty = (repeatPasswordTextField.text?.isEmpty ?? true)
            let passwordIsEmpty = string.isEmpty
            let passwordMatching = !passwordIsEmpty &&
                string == repeatPasswordTextField.text &&
                !repeatPasswordIsEmpty
            hidePasswordWarning(passwordMatching || repeatPasswordIsEmpty || passwordIsEmpty)
            let privateKeyIsOK = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || additionMode == .createWallet)
            let everyFieldIsOK = passwordMatching && privateKeyIsOK
            enterButton.isEnabled = everyFieldIsOK
        case repeatPasswordTextField:
            let passwordIsEmpty = (passwordTextField.text?.isEmpty ?? true)
            let repeatPasswordIsEmpty = string.isEmpty
            let passwordMatching = !repeatPasswordIsEmpty &&
                string == passwordTextField.text &&
                !passwordIsEmpty
            hidePasswordWarning(passwordMatching || passwordIsEmpty || repeatPasswordIsEmpty)
            let privateKeyIsOK = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || additionMode == .createWallet)
            let everyFieldIsOK = passwordMatching && privateKeyIsOK
            enterButton.isEnabled = everyFieldIsOK
        default:
            let privateKeyFieldIsOk =
                (
                additionMode == .importWallet
                && !(enterPrivateKeyTextField.text?.isEmpty ?? true)
                )
                || additionMode == .createWallet
                ? true
                : false

            let everyFieldIsOK = !string.isEmpty &&
                passwordTextField.text == repeatPasswordTextField.text &&
                !(passwordTextField.text?.isEmpty ?? true) && privateKeyFieldIsOk

            enterButton.isEnabled = everyFieldIsOK

        }

    }

    func addWalletDependingOnMode(_ walletName: String, withKey: String, withPassword: String, isAtLeastOneExists: Bool) {
        
        switch additionMode {
        case .createWallet:
            //Create new wallet
            showChooseAlert(forWallet: walletName, withPassword: withPassword)
            
        default:
            //Import wallet
            guard let importMode = importMode else { return }
            
            switch importMode {
            case .mnemonics:
                keysService.createNewHDWallet(withName: walletName, password: withPassword, mnemonics: withKey) { [weak self] (keyWalletModel, error) in
                    DispatchQueue.main.async {
                        self?.animation.waitAnimation(isEnabled: false,
                                                      on: (self?.view)!)
                    }
                    if let error = error {
                        print(error)
                    } else {
                        switch isAtLeastOneExists {
                        case true:
                            self?.savingWallet(wallet: keyWalletModel, withPassword: withPassword)
                        case false:
                            self?.addPincode(toWallet: keyWalletModel, with: withPassword)
                        }
                    }
                }
            case .privateKey:
                keysService.addNewWalletWithPrivateKey(withName: walletName,
                                                       key: withKey,
                                                       password: withPassword)
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
                        
                        switch isAtLeastOneExists {
                        case true:
                            self?.savingWallet(wallet: wallet, withPassword: withPassword)
                        case false:
                            self?.addPincode(toWallet: wallet, with: withPassword)
                        }
                    }
                }
            }
        }
    }
    
    
    func savingWallet(wallet: KeyWalletModel?, withPassword: String) {
        DispatchQueue.main.async { [weak self] in
            self?.animation.waitAnimation(isEnabled: true,
                                          notificationText: "Saving wallet",
                                          on: (self?.view)!)
        }
        self.localStorage.saveWallet(wallet: wallet) { [weak self] (error) in
            if error == nil {
                self?.createPassword(withPassword, forWallet: wallet)
                DispatchQueue.main.async { [weak self] in
                    self?.animation.waitAnimation(isEnabled: false,
                                                  on: (self?.view)!)
                }
                self?.localStorage.selectWallet(wallet: wallet, completion: {
                    DispatchQueue.global().async {
                        if !UserDefaultKeys().isEtherAdded {
                            AppController().addFirstToken(for: wallet!, completion: { (error) in
                                if error == nil {
                                    UserDefaultKeys().setEtherAdded()
                                    UserDefaults.standard.synchronize()
                                    self?.goToApp()
                                } else {
                                    showErrorAlert(for: self!, error: error, completion: {
                                        self?.goToApp()
                                    })
                                }
                            })
                        } else {
                            self?.goToApp()
                        }
                    }
                    
                })
            } else {
                fatalError("String(describing: error)")
            }
        }
    }
    
    func goToApp() {
        let tabViewController = AppController().goToApp()
        tabViewController.view.backgroundColor = UIColor.white
        self.present(tabViewController, animated: true, completion: nil)
    }
    
    func showChooseAlert(forWallet withName: String, withPassword: String) {
        let isAtLeastOneWalletExists = UserDefaults.standard.bool(forKey: "atLeastOneWalletExists")
        let alertController = UIAlertController(title: "Wallet type", message: "How would you like to create your wallet?", preferredStyle: .alert)
        let actionMnemonics = UIAlertAction(title: "Mnemonics", style: .default) { [weak self] (_) in
            let mnemonicsViewController = MnemonicsViewController(name: withName, password: withPassword)
            self?.navigationController?.pushViewController(mnemonicsViewController, animated: true)
        }
        
        let actionPrivateKey = UIAlertAction(title: "Private Key", style: .default) { [weak self] _ in
            self?.keysService.createNewWallet(withName: withName,
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
                        self?.savingWallet(wallet: wallet, withPassword: withPassword)
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
    
    func checkPasswordsMatch() -> Bool {
        return !((!(passwordTextField.text?.isEmpty ?? true) ||
            !(repeatPasswordTextField.text?.isEmpty ?? true)) &&
            passwordTextField.text != repeatPasswordTextField.text) ||
        repeatPasswordTextField.text?.isEmpty ?? true || passwordTextField.text?.isEmpty ?? true
    }

    func setColor(_ match: Bool) {
        let color = match ? UIColor.darkGray : UIColor.red
        repeatPasswordTextField.textColor = color
        passwordTextField.textColor = color
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
            hidePasswordWarning(true)
            passwordsMatch(true)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        
        isEnterButtonEnabled(afterChanging: textField, with: futureString)

        updateEnterButtonAlpha()

        textField.returnKeyType = enterButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.textColor = UIColor.darkGray
        
        guard textField == repeatPasswordTextField ||
            textField == passwordTextField else {
                return true
        }
        let match = checkPasswordsMatch()
        hidePasswordWarning(match)
        passwordsMatch(match)
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

