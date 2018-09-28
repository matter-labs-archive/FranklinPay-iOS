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

    var wallet: KeyWalletModel?
    var token: ERC20TokenModel?
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
    let transactionsService = TransactionsService()

    let animation = AnimationController()

    var screenState: AppState = .ETH {
        didSet {
            print(screenState)
        }
    }

    let tokenDropdownManager = TokenDropdownManager()
    let walletDropdownManager = WalletDropdownManager()

    convenience init(wallet: KeyWalletModel,
                     tokenBalance: String,
                     token: ERC20TokenModel) {
        self.init()
        self.wallet = wallet
        self.tokenBalance = tokenBalance
        self.token = token
    }

    convenience init(tokenAddress: String?,
                     amount: BigUInt,
                     destinationAddress: String,
                     isFromDeepLink: Bool = true) {
        self.init()
        token = ERC20TokenModel(isEther: false)
        let decimals = Float(1000000000000000000)
        let amountFloat = Float(amount)
        let resultAmount = Float(amountFloat / decimals)
        self.amountInString = String(resultAmount)
        self.destinationAddress = destinationAddress
        let walletFromDatabase = LocalDatabase().getWallet()
        guard let wallet = walletFromDatabase else {
            return
        }
        self.wallet = wallet
        self.isFromDeepLink = isFromDeepLink
        if tokenAddress != nil {
            Web3SwiftService().getERCBalance(for: tokenAddress!,
                    address: wallet.address) { (result, error) in
                DispatchQueue.main.async { [weak self] in
                    self?.tokenBalance = result ?? ""
                }
            }
        } else {
            Web3SwiftService().getETHbalance(for: wallet) { (result, error) in
                DispatchQueue.main.async { [weak self] in
                    self?.tokenBalance = result ?? ""
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Send"
        if !isFromDeepLink {
            token = CurrentToken.currentToken
        }
        wallet = localStorage.getWallet()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let wallet = wallet else {
            return
        }
        Web3SwiftService().getETHbalance(for: wallet) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.tokenBalance = result ?? ""
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stackView.isUserInteractionEnabled = true
        self.dropDownView.removeFromSuperview()
    }

    private func hideSendButton(_ hidden: Bool = true) {
        sendButton.alpha = hidden ? 0.5 : 1
        sendButton.isEnabled = hidden ? false : true
    }

    private func setup() {
        self.hideKeyboardWhenTappedAround()
        addressFromLabel.text = "From: \(wallet?.address ?? "")"
        addGestureRecognizer()
        closeButton.isHidden = true
        //balanceOnWalletLabel.text = "Balance of \(walletName ?? "") wallet: \(tokenBalance ?? "0")"
        tokenNameLabel.text = token?.symbol.uppercased() ?? "ETH"
        hideSendButton(true)
        enterAddressTextField.text = destinationAddress
        amountTextField.text = amountInString
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

    // MARK: - Dropdown
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
        guard let wallet = localStorage.getWallet() else {
            return
        }
        tokenDropdownManager.tokens = localStorage.getAllTokens(for: wallet, forNetwork: Int64(CurrentNetwork.currentNetwork?.chainID ?? 1))
        self.view.addSubview(dropDownView)
        stackView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.dropDownView.alpha = 1.0
        }, completion: nil)
    }

    func createDropdownView(withManager manager: ManagerType) -> UIView {
        guard let sv = addressFromView.superview else {
            return UIView()
        }
        let frame = CGRect(x: sv.frame.origin.x, y: addressFromView.frame.origin.y + addressFromView.frame.height + sv.frame.origin.y, width: addressFromView.frame.width, height: 150)
        dropDownView = UIView(frame: frame)
        switch manager {
        case .Tokens:
            guard let wallet = wallet else {
                return UIView()
            }
            tokenDropdownManager.tokens = localStorage.getAllTokens(for: wallet, forNetwork: CurrentNetwork().getNetworkID())
            tokenDropdownManager.wallet = self.wallet
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

    @IBAction func scanQR(_ sender: UIButton) {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }

    func prepareTransation(withPassword: String?) {

        guard let amount = amountTextField.text,
              let destinationAddress = enterAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return
        }

        if token?.address == "" {
            transactionsService.prepareTransactionForSendingEther(destinationAddressString: destinationAddress, amountString: amount, gasLimit: 21000) { [weak self] (result) in
                switch result {
                case .Success(let transaction):
                    guard let gasPrice = self?.gasPriceTextField.text else {
                        return
                    }
                    guard let gasLimit = self?.gasLimitTextField.text else {
                        return
                    }
                    guard let name = self?.wallet?.name else {
                        return
                    }
                    let dict: [String: Any] = [
                        "gasPrice": gasPrice,
                        "gasLimit": gasLimit,
                        "transaction": transaction,
                        "amount": amount,
                        "name": name,
                        "fromAddress": self!.wallet?.address ?? "",
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
            transactionsService.prepareTransactionForSendingERC(destinationAddressString: destinationAddress,
                                                                amountString: amount,
                                                                gasLimit: 21000,
                                                                tokenAddress: (token?.address) ?? "") { [weak self] (result) in
                switch result {
                case .Success(let transaction):
                    guard let gasPrice = self?.gasPriceTextField.text else {
                        return
                    }
                    guard let gasLimit = self?.gasLimitTextField.text else {
                        return
                    }
                    guard let name = self?.wallet?.name else {
                        return
                    }
                    let dict: [String: Any] = [
                        "gasPrice": gasPrice,
                        "gasLimit": gasLimit,
                        "transaction": transaction,
                        "amount": amount,
                        "name": name,
                        "fromAddress": self!.wallet?.address ?? "",
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
        guard let wallet = wallet else {
            return
        }
        guard let token = token else {
            return
        }
        localStorage.selectWallet(wallet: wallet) { [weak self] in
            CurrentToken.currentToken = token
            self?.checkPassword { (password) in
                self?.prepareTransation(withPassword: password)
            }
        }

    }

    func checkPassword(completion: @escaping (String?) -> Void) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                    account: "\(self.wallet?.name ?? "")-password",
                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            completion(keychainPassword)
        } catch {
            //            fatalError("Error reading password from keychain - \(error)")
            completion(nil)
        }
    }

    func enterPincode(for data: [String: Any]?, withPassword: String?) {
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

// MARK: - Dropdowns Delegates
extension SendSettingsViewController: WalletSelectionDelegate, TokenSelectionDelegate {
    func didSelectWallet(wallet: KeyWalletModel) {
        self.wallet = wallet
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
        self.token = token
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
                if token != ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth") {
                    token = ERC20TokenModel(name: "", address: "", decimals: "", symbol: "")
                }
                amountTextField.text = Web3.Utils.formatToEthereumUnits(
                        amount,
                        toUnits: .eth,
                        decimals: 4)
            }
        } else {
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

    private func isSendButtonEnabled(afterChanging textField: UITextField, with string: String) -> Bool {
        var hardExpression = true
        hardExpression = hardExpression && !string.isEmpty
                && (token != nil) && (wallet != nil)
                && ((Double(tokenBalance ?? "0") ?? 0.0) > Double(0))
        if textField != amountTextField {
            hardExpression = hardExpression
                    && !string.isEmpty
                    && !(amountTextField.text?.isEmpty ?? true)
                    && ((Float(amountTextField.text ?? "0.0") ?? 0.0) > Float(0))
        } else {
            hardExpression = hardExpression
                    && !string.isEmpty
                    && ((Float(string) ?? 0.0) > Float(0))
        }
        return hardExpression
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        hideSendButton(true)

        let hardExpression = isSendButtonEnabled(afterChanging: textField, with: futureString)

        hideSendButton(!hardExpression)

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
            guard Int((gasLimitTextField.text ?? "0"))! < 21000 else {
                gasLimitTextField.text = "21000"
                return true
            }
            guard Int((gasLimitTextField.text ?? "0"))! > 5 else {
                gasLimitTextField.text = "5"
                return true
            }
        }
        if textField == gasPriceTextField {
            guard let _ = Int((gasPriceTextField.text ?? "")) else {
                gasPriceTextField.textColor = UIColor.red
                return true
            }
            guard Int((gasPriceTextField.text ?? "0"))! < 100 else {
                gasPriceTextField.text = "100"
                return true
            }
            guard Int((gasPriceTextField.text ?? "0"))! > 5 else {
                gasPriceTextField.text = "5"
                return true
            }
        }
        return true
    }
}
