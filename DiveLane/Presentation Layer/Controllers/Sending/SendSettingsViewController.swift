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
import PlasmaSwiftLib
import struct EthereumAddress.EthereumAddress

class SendSettingsViewController: UIViewController {

    // MARK: Outlets
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

    // MARK: - Dropdown Outlets
    @IBOutlet weak var heightWalletsConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletsDropdownTableView: UITableView!
    @IBOutlet weak var heightTokensConstraint: NSLayoutConstraint!
    @IBOutlet weak var tokensDropdownTableView: UITableView!
    @IBOutlet weak var arrowDownWalletsImageView: UIImageView!
    @IBOutlet weak var arrowDownTokensImageView: UIImageView!
    // MARK: Variables
    var wallet: KeyWalletModel?
    var token: ERC20TokenModel?
    var utxo: ListUTXOsModel?
    var tokenBalance: String?
    var isFromDeepLink: Bool = false
    var amountInString: String?
    var destinationAddress: String?
    let localStorage = LocalDatabase()
    let transactionsService = TransactionsService()
    let animation = AnimationController()

    var currentUTXOs = [ListUTXOsModel]()
    var blockchainState: AppState = .ETH

    var tokenDropdownManager: TokenDropdownManager?
    var walletDropdownManager: WalletDropdownManager?

    convenience init(_ plasmaContract: String = plasmaContract,
                     wallet: KeyWalletModel,
                     tokenBalance: String,
                     token: ERC20TokenModel = ERC20TokenModel(isEther: true)) {
        self.init()
        self.wallet = wallet
        self.tokenBalance = tokenBalance
        self.token = token
        self.destinationAddress = plasmaContract
    }

    // MARK: Initializers for launching from deeplink
    convenience init(wallet: KeyWalletModel,
                     tokenBalance: String,
                     token: ERC20TokenModel) {
        self.init()
        self.wallet = wallet
        self.tokenBalance = tokenBalance
        self.token = token
    }

    // MARK: Initializers for launching from deeplink
    convenience init(destinationAddress: String) {
        self.init()
        self.destinationAddress = destinationAddress
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
                    address: wallet.address) { (result, _) in
                DispatchQueue.main.async { [weak self] in
                    self?.tokenBalance = result ?? ""
                }
            }
        } else {
            Web3SwiftService().getETHbalance(for: wallet) { (result, _) in
                DispatchQueue.main.async { [weak self] in
                    self?.tokenBalance = result ?? ""
                }
            }
        }
    }

    // MARK: Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arrowDownWalletsImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapFrom)))
        arrowDownWalletsImageView.isUserInteractionEnabled = true
        arrowDownTokensImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToken)))
        arrowDownTokensImageView.isUserInteractionEnabled = true
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
        Web3SwiftService().getETHbalance(for: wallet) { [weak self] (result, _) in
            DispatchQueue.main.async {
                self?.tokenBalance = result ?? ""
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stackView.isUserInteractionEnabled = true
    }

    private func hideSendButton(_ hidden: Bool = true) {
        sendButton.alpha = hidden ? 0.5 : 1
        sendButton.isEnabled = hidden ? false : true
    }

    private func setup() {
        self.hideKeyboardWhenTappedAround()
        addressFromLabel.text = "\(wallet?.address.hideExtraSymbolsInAddress() ?? "")"
        addGestureRecognizer()
        closeButton.isHidden = true
        tokenNameLabel.text = token?.symbol.uppercased() ?? "ETH"
        hideSendButton(true)
        enterAddressTextField.text = destinationAddress
        amountTextField.text = amountInString
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
        let transform = self.heightWalletsConstraint.constant > 0 ?
            CGAffineTransform.identity :
            CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.arrowDownWalletsImageView.transform = transform
        }
        if blockchainState == .ETH {
            prepareDropdownViewForEtherBlockchain(withManager: .Wallets)
        } else {
            prepareDropdownViewForPlasmaBlockchain(withManager: .Wallets)
        }
        self.heightWalletsConstraint.constant = self.heightWalletsConstraint.constant > 0 ? 0 : 100
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    @objc func didTapToken() {
        let transform = self.heightTokensConstraint.constant > 0 ?
            CGAffineTransform.identity :
            CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.arrowDownTokensImageView.transform = transform
        }
        if blockchainState == .ETH {
            prepareDropdownViewForEtherBlockchain(withManager: .Tokens)
        } else {
            prepareDropdownViewForPlasmaBlockchain(withManager: .Tokens)
        }
        heightTokensConstraint.constant = heightTokensConstraint.constant > 0 ? 0 : 100
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    func prepareDropdownViewForEtherBlockchain(withManager manager: ManagerType) {
        tokenDropdownManager = TokenDropdownManager()
        walletDropdownManager = WalletDropdownManager()
        switch manager {
        case .Tokens:
            guard let wallet = wallet else {
                return
            }
            tokenDropdownManager?.tokens = localStorage.getAllTokens(for: wallet,
                                                                    forNetwork: CurrentNetwork().getNetworkID())
            tokenDropdownManager?.wallet = wallet
            tokenDropdownManager?.utxos = []
        case .Wallets:
            walletDropdownManager?.wallets = localStorage.getAllWallets()
        }
        let tableView = (manager == .Wallets ? walletsDropdownTableView : tokensDropdownTableView)!
        let cellToRegister = manager == .Wallets ? "WalletCellDropdown" : "TokenCellDropdown"
        let nib = UINib(nibName: cellToRegister, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellToRegister)
        tableView.delegate = manager == .Wallets ? walletDropdownManager : tokenDropdownManager
        tableView.dataSource = manager == .Wallets ? walletDropdownManager : tokenDropdownManager

        walletDropdownManager?.isPlasma = false
        walletDropdownManager?.delegate = self
        tokenDropdownManager?.isPlasma = false
        tokenDropdownManager?.delegate = self
    }

    func getUTXOs() {
        DispatchQueue.main.async { [weak self] in
            self?.animation.waitAnimation(isEnabled: true, notificationText: "Getting UTXOs from Plasma", on: (self?.view)!)
        }
        currentUTXOs = []
        guard let network = CurrentNetwork.currentNetwork else {return}
        guard let wallet = wallet else {
            return
        }
        guard let ethAddress = EthereumAddress(wallet.address) else {return}
        let mainnet = network.chainID == Networks.Mainnet.chainID
        let testnet = !mainnet && network.chainID == Networks.Rinkeby.chainID
        if !testnet && !mainnet {return}
        MatterService().getListUTXOs(for: ethAddress, onTestnet: testnet) { [weak self] (result) in
            switch result {
            case .Success(let utxos):
                DispatchQueue.main.async {
                    self?.currentUTXOs = utxos
                    self?.animation.waitAnimation(isEnabled: false, notificationText: "Getting UTXOs from Plasma", on: (self?.view)!)
                }
            case .Error(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.animation.waitAnimation(isEnabled: false, notificationText: "Getting UTXOs from Plasma", on: (self?.view)!)
                }
            }
        }
    }

    func prepareDropdownViewForPlasmaBlockchain(withManager manager: ManagerType) {
        tokenDropdownManager = TokenDropdownManager()
        walletDropdownManager = WalletDropdownManager()
        switch manager {
        case .Tokens:
            guard let wallet = wallet else {
                return
            }
            tokenDropdownManager?.tokens = []
            tokenDropdownManager?.utxos = currentUTXOs
            tokenDropdownManager?.wallet = wallet
        case .Wallets:
            walletDropdownManager?.wallets = localStorage.getAllWallets()
        }

        let tableView = (manager == .Wallets ? walletsDropdownTableView : tokensDropdownTableView)!
        let cellToRegister = manager == .Wallets ? "WalletCellDropdown" : "TokenCellDropdown"
        let nib = UINib(nibName: cellToRegister, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellToRegister)
        tableView.delegate = manager == .Wallets ? walletDropdownManager : tokenDropdownManager
        tableView.dataSource = manager == .Wallets ? walletDropdownManager : tokenDropdownManager

        walletDropdownManager?.isPlasma = true
        walletDropdownManager?.delegate = self
        tokenDropdownManager?.isPlasma = true
        tokenDropdownManager?.delegate = self
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

        guard let token = token else {return}

        if token == ERC20TokenModel(isEther: true) && destinationAddress == plasmaContract {
            transactionsService.prepareTransactionToContract(data: [], contractAbi: plasmaABI, contractAddress: plasmaContract, method: "deposit", value: amount) { [weak self] (result) in
                self?.transactionOperation(isContract: true,
                                           result: result,
                                           amount: amount,
                                           destinationAddress: destinationAddress,
                                           password: withPassword)
            }
        } else if token == ERC20TokenModel(isEther: true) {
            transactionsService.prepareTransactionForSendingEther(destinationAddressString: destinationAddress,
                                                                  amountString: amount,
                                                                  gasLimit: 21000) { [weak self] (result) in
                                                                    self?.transactionOperation(result: result,
                                                                                               amount: amount,
                                                                                               destinationAddress: destinationAddress,
                                                                                               password: withPassword)
            }
        } else {
            transactionsService.prepareTransactionForSendingERC(destinationAddressString: destinationAddress,
                                                                amountString: amount,
                                                                gasLimit: 21000,
                                                                tokenAddress: token.address) { [weak self] (result) in
                                                                    self?.transactionOperation(result: result,
                                                                                               amount: amount,
                                                                                               destinationAddress: destinationAddress,
                                                                                               password: withPassword)
            }
        }
    }

    func transactionOperation(isContract: Bool = false, result: Result<TransactionIntermediate>, amount: String, destinationAddress: String, password: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.animation.waitAnimation(isEnabled: false,
                                          on: (self?.view)!)
        }
        switch result {
        case .Success(let transaction):
            guard let name = self.wallet?.name else {
                return
            }
            let gasPrice = transaction.options?.gasPrice ?? (BigUInt(self.gasPriceTextField.text ?? "0") ?? "0")
            let gasLimit = transaction.options?.gasLimit ?? (BigUInt(self.gasLimitTextField.text ?? "0") ?? "0")
            let dict: [String: Any] = [
                "gasPrice": gasPrice == gasPrice,
                "gasLimit": gasLimit == gasLimit,
                "transaction": transaction,
                "amount": amount,
                "name": name,
                "fromAddress": self.wallet?.address ?? "",
                "toAddress": destinationAddress]

            //self?.sendFunds(dict: dict, enteredPassword: withPassword)
            showAccessAlert(for: self, with: "Send the transaction?", completion: { [weak self] (result) in
                if result {
                    self?.enterPincode(for: dict, isContract: isContract, withPassword: password)
                } else {
                    showErrorAlert(for: self!, error: TransactionErrors.PreparingError, completion: {

                    })
                }

            })
        case .Error(let error):
            showErrorAlert(for: self, error: error, completion: {

            })
        }
    }

    @IBAction func send(_ sender: UIButton) {
        guard let wallet = wallet else {
            return
        }
        if blockchainState == .ETH {
            guard let token = token else {
                return
            }
            animation.waitAnimation(isEnabled: true,
                                    notificationText: "Preparing transaction",
                                    on: self.view)
            localStorage.selectWallet(wallet: wallet) { [weak self] in
                CurrentToken.currentToken = token
                self?.checkPassword { [weak self] (password) in
                    self?.prepareTransation(withPassword: password)
                }
            }
        } else {
            animation.waitAnimation(isEnabled: true,
                                    notificationText: "Preparing transaction",
                                    on: self.view)
            self.checkPassword { [weak self] (password) in
                self?.preparePlasmaTransaction(withPassword: password)
            }
        }
    }

    func preparePlasmaTransaction(withPassword: String?) {
        guard let utxo = utxo else {return}
        guard let input = utxo.toTransactionInput() else {return}
        let inputs = [input]

        guard let amount = amountTextField.text,
            let destinationAddress = enterAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
        }
        guard let floatAmount = Float(amount) else {return}
        let uintAmount = BigUInt( floatAmount * 1000000 )
        let amountSendInETH = uintAmount * BigUInt(1000000000000)
        let amountStayInETH = input.amount - amountSendInETH

        guard let ethDestinationAddress = EthereumAddress(destinationAddress) else {return}
        guard let currentAddress = KeysService().selectedWallet()?.address else {return}
        guard let ethCurrentAddress = EthereumAddress(currentAddress) else {return}

        guard let output1 = TransactionOutput(outputNumberInTx: 0,
                                             receiverEthereumAddress: ethDestinationAddress,
                                             amount: amountSendInETH) else {return}
        guard let output2 = TransactionOutput(outputNumberInTx: 1,
                                              receiverEthereumAddress: ethCurrentAddress,
                                              amount: amountStayInETH) else {return}

        let outputs = [output1, output2]

        guard let transaction = Transaction(txType: .split, inputs: inputs, outputs: outputs) else {
            showErrorAlert(for: self, error: TransactionErrors.PreparingError, completion: {
            })
            return
        }
        showAccessAlert(for: self, with: "Send the transaction?", completion: { [weak self] (result) in
            if result {
                self?.enterPincode(for: transaction, withPassword: withPassword)
            } else {
                showErrorAlert(for: self!, error: TransactionErrors.PreparingError, completion: {

                })
            }

        })
    }

    func checkPassword(completion: @escaping (String?) -> Void) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                    account: "\(self.wallet?.name ?? "")-password",
                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            completion(keychainPassword)
        } catch {
            completion(nil)
        }
    }

    func enterPincode(for data: [String: Any]?, isContract: Bool = false, withPassword: String?) {
        guard let data = data else {
            showErrorAlert(for: self, error: TransactionErrors.PreparingError, completion: {

            })
            return
        }
        let enterPincode = EnterPincodeViewController(from: .transaction, for: data, isContract: isContract, withPassword: withPassword ?? "", isFromDeepLink: isFromDeepLink)
        self.navigationController?.pushViewController(enterPincode, animated: true)
    }

    func enterPincode(for transaction: Transaction, withPassword: String?) {
        let enterPincode = EnterPincodeViewController(from: .transaction, for: transaction, withPassword: withPassword ?? "", isFromDeepLink: isFromDeepLink)
        self.navigationController?.pushViewController(enterPincode, animated: true)
    }

    @IBAction func closeAction(_ sender: UIButton) {
        let startViewController = AppController().goToApp()
        startViewController.view.backgroundColor = UIColor.white
        UIApplication.shared.keyWindow?.rootViewController = startViewController
    }

    @IBAction func changeBlockchain(_ sender: UISegmentedControl) {
        currentUTXOs = []
        if sender.selectedSegmentIndex == 0 {
            blockchainState = .ETH
            tokenNameLabel.text = token?.symbol.uppercased() ?? "ETH"
        } else {
            blockchainState = .Plasma
            tokenNameLabel.text = "Choose UTXO"
            self.getUTXOs()
        }
    }
}

// MARK: Dropdowns Delegates
extension SendSettingsViewController: WalletSelectionDelegate, TokenSelectionDelegate {
    func didSelectUTXO(utxo: ListUTXOsModel) {
        let balance = Web3Utils.formatToEthereumUnits(utxo.value,
                                                      toUnits: .eth,
                                                      decimals: 6,
                                                      decimalSeparator: ".")
        self.tokenNameLabel.text = balance
        self.utxo = utxo
        self.heightTokensConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func didSelectWallet(wallet: KeyWalletModel) {
        self.wallet = wallet
        localStorage.selectWallet(wallet: wallet) { [weak self] in
            self?.addressFromLabel.text = wallet.address
            self?.heightWalletsConstraint.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self?.view.layoutIfNeeded()
            }, completion: nil)
            if self?.blockchainState == .Plasma {
                self?.getUTXOs()
            }
        }
    }

    func didSelectToken(token: ERC20TokenModel) {
        self.tokenNameLabel.text = token.symbol.uppercased()
        self.token = token
        CurrentToken.currentToken = token
        self.heightTokensConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: QRCodeReaderViewController Delegate Methods
extension SendSettingsViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let value = result.value

        if let parsed = Web3.EIP67CodeParser.parse(value) {
            enterAddressTextField.text = parsed.address.address
            if let amount = parsed.amount {
                if token != ERC20TokenModel(isEther: true) {
                    token = ERC20TokenModel(name: "", address: "", decimals: "", symbol: "")
                }
                amountTextField.text = Web3.Utils.formatToEthereumUnits(
                        amount,
                        toUnits: .eth,
                        decimals: 4)
            }
        } else {
            if EthereumAddress(value) != nil {
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
        if blockchainState == .Plasma {
            guard let utxo = utxo else {return false}
            let balance = Web3Utils.formatToEthereumUnits(utxo.value,
                                                          toUnits: .eth,
                                                          decimals: 6,
                                                          decimalSeparator: ".")
            if textField != amountTextField {
                let amount = Float(amountTextField.text ?? "0.0") ?? 0.0
                hardExpression = hardExpression
                    && !string.isEmpty
                    && (wallet != nil)
                    && !(amountTextField.text?.isEmpty ?? true)
                    && (amount > Float(0))
                    && (amount <= Float(balance ?? "0.0") ?? 0.0)
            } else {
                let amount = Float(string) ?? 0.0
                hardExpression = hardExpression
                    && !string.isEmpty
                    && (wallet != nil)
                    && (amount > Float(0))
                    && (amount <= Float(balance ?? "0.0") ?? 0.0)
                    && enterAddressTextField.text != nil
            }
        } else {
            hardExpression = hardExpression && !string.isEmpty
                && token != nil && wallet != nil
                && Double(tokenBalance ?? "0") ?? 0.0 > Double(0)
            let balance = Float(tokenBalance ?? "0") ?? 0.0
            if textField != amountTextField {
                let amount = (Float(amountTextField.text ?? "0.0") ?? 0.0)
                hardExpression = hardExpression
                    && !(amountTextField.text?.isEmpty ?? true)
                    && amount > Float(0)
                    && amount <= balance
            } else {
                hardExpression = hardExpression
                    && Float(string) ?? 0.0 > Float(0)
                    && Float(string) ?? 0.0 <= balance
            }
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
            guard Float(amountTextField.text ?? "") != nil else {
                amountTextField.textColor = UIColor.red
                return true
            }
        }
        if textField == gasLimitTextField {
            guard Int(gasLimitTextField.text ?? "") != nil else {
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
            guard Int(gasPriceTextField.text ?? "") != nil else {
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
