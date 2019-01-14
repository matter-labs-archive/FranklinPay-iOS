////
////  SendSettingsViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 08/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//import QRCodeReader
//import Web3swift
//import BigInt
//import EthereumAddress
//
//class SendSettingsViewController: UIViewController {
//
//    // MARK: Outlets
//    @IBOutlet weak var closeButton: UIButton!
//    @IBOutlet weak var addressFromLabel: UILabel!
//    @IBOutlet weak var enterAddressTextField: UITextField!
//    @IBOutlet weak var amountTextField: UITextField!
//    @IBOutlet weak var tokenNameLabel: UILabel!
//    @IBOutlet weak var gasPriceTextField: UITextField!
//    @IBOutlet weak var gasLimitTextField: UITextField!
//    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var qrButton: UIButton!
//    @IBOutlet var textFields: [UITextField]!
//    @IBOutlet weak var closeView: UIView!
//    @IBOutlet weak var addressFromView: UIView!
//    @IBOutlet weak var stackView: UIStackView!
//    @IBOutlet weak var blockchain: UISegmentedControl!
//
//    // MARK: - Dropdown Outlets
//    @IBOutlet weak var heightWalletsConstraint: NSLayoutConstraint!
//    @IBOutlet weak var walletsDropdownTableView: UITableView!
//    @IBOutlet weak var heightTokensConstraint: NSLayoutConstraint!
//    @IBOutlet weak var tokensDropdownTableView: UITableView!
//    @IBOutlet weak var arrowDownWalletsImageView: UIImageView!
//    @IBOutlet weak var arrowDownTokensImageView: UIImageView!
//    // MARK: Variables
//    var wallet: WalletModel?
//    var token: ERC20TokenModel?
//    var utxo: PlasmaUTXOs?
//    var tokenBalance: String?
//    var isFromDeepLink: Bool = false
//    var amountInString: String?
//    var destinationAddress: String?
//    let localStorage = WalletsService()
//    let transactionsService = Web3Service()
//    let animation = AnimationController()
//
//    var currentUTXOs = [PlasmaUTXOs]()
//    var blockchainState: AppState = .ETH
//
//    var tokenDropdownManager: TokenDropdownManager?
//    var walletDropdownManager: WalletDropdownManager?
//
//    convenience init(_ plasmaContract: String = PlasmaContract.plasmaAddress,
//                     tokenBalance: String,
//                     token: ERC20TokenModel = ERC20TokenModel(isEther: true)) {
//        self.init()
//        self.tokenBalance = tokenBalance
//        self.token = token
//        self.destinationAddress = plasmaContract
//    }
//
//    // MARK: Initializers for launching from deeplink
//    convenience init(tokenBalance: String,
//                     token: ERC20TokenModel) {
//        self.init()
//        self.tokenBalance = tokenBalance
//        self.token = token
//    }
//
//    // MARK: Initializers for launching from deeplink
//    convenience init(destinationAddress: String) {
//        self.init()
//        self.destinationAddress = destinationAddress
//    }
//
//    // Plasma init
//    convenience init(amount: String?,
//                     destinationAddress: String,
//                     isFromDeepLink: Bool = true) {
//        self.init()
//        self.amountInString = amount
//        self.destinationAddress = destinationAddress
//        self.isFromDeepLink = isFromDeepLink
//        blockchainState = .Plasma
////        blockchainState = .Plasma
////        tokenNameLabel.text = "Choose UTXO"
//
//        //self.getUTXOs()
//    }
//
//    convenience init(tokenAddress: String?,
//                     amount: BigUInt,
//                     destinationAddress: String,
//                     isFromDeepLink: Bool = true) {
//        self.init()
//        let decimals = Float(1000000000000000000)
//        let amountFloat = Float(amount)
//        let resultAmount = Float(amountFloat / decimals)
//        let ta = tokenAddress ?? ""
//        if ta.isEmpty || ta == "0" {
//            self.token = ERC20TokenModel(isEther: true)
//        } else {
//            self.token = ERC20TokenModel(name: "Some token",
//                                          address: ta,
//                                          decimals: "18",
//                                          symbol: "Some token")
//        }
//        self.amountInString = String(resultAmount)
//        self.destinationAddress = destinationAddress
//    }
//
//    // MARK: Lyfecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        arrowDownWalletsImageView.addGestureRecognizer(
//            UITapGestureRecognizer(
//                target: self,
//                action: #selector(didTapFrom)))
//        arrowDownWalletsImageView.isUserInteractionEnabled = true
//        arrowDownTokensImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToken)))
//        arrowDownTokensImageView.isUserInteractionEnabled = true
//        self.navigationItem.setRightBarButton(settingsWalletBarItem(), animated: false)
//    }
//
//    private func settingsWalletBarItem() -> UIBarButtonItem {
//        let addButton = UIBarButtonItem(image: UIImage(named: "settings_blue"),
//                                        style: .plain,
//                                        target: self,
//                                        action: #selector(settingsWallet))
//        return addButton
//    }
//
//    @objc func settingsWallet() {
//        //let walletsViewController = WalletsViewController()
//        let settingsViewController = SettingsViewController()
//        self.navigationController?.pushViewController(settingsViewController, animated: true)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.title = "Send"
//        if !isFromDeepLink {
//            token = CurrentToken.currentToken
//        }
//        self.setup()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        DispatchQueue.global().async { [weak self] in
//            guard let selectedWallet = try? self?.localStorage.getSelectedWallet() else {
//                DispatchQueue.main.async {
//                    self?.wallet = nil
//                    self?.tokenBalance = nil
//                }
//                return
//            }
//            self?.wallet = selectedWallet
//            guard let wallet = selectedWallet else {
//                DispatchQueue.main.async {
//                    self?.tokenBalance = nil
//                }
//                return
//            }
//            DispatchQueue.main.async {
//                self?.addressFromLabel.text = "\(wallet.address.hideExtraSymbolsInAddress() )"
//            }
//            if self?.blockchainState == .Plasma {
//                DispatchQueue.main.async {
//                    self?.tokenBalance = nil
//                }
//                self?.getUTXOs()
//                return
//            }
//            let balance: String?
//            guard let token = self?.token else {
//                DispatchQueue.main.async {
//                    self?.tokenBalance = nil
//                }
//                return
//            }
//            if token == ERC20TokenModel(isEther: true) {
//                guard let result = try? Web3Service().getETHbalance(for: wallet) else {
//                    DispatchQueue.main.async {
//                        self?.tokenBalance = nil
//                    }
//                    return
//                }
//                balance = result
//            } else {
//                guard let result = try? Web3Service().getERC20balance(for: wallet, token: token) else {
//                    DispatchQueue.main.async {
//                        self?.tokenBalance = nil
//                    }
//                    return
//                }
//                balance = result
//            }
//            DispatchQueue.main.async { [weak self] in
//                self?.tokenBalance = balance
//            }
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        //self.stackView.isUserInteractionEnabled = true
//    }
//
//    private func hideSendButton(_ hidden: Bool = true) {
//        sendButton.alpha = hidden ? 0.5 : 1
//        sendButton.isEnabled = hidden ? false : true
//    }
//
//    private func setup() {
//        self.hideKeyboardWhenTappedAround()
//        addGestureRecognizer()
//        closeButton.isHidden = true
//        tokenNameLabel.text = blockchainState == .Plasma ?
//            "CHOOSE UTXO" :
//            (token?.symbol.uppercased() ?? "ETH")
//        hideSendButton(true)
//        enterAddressTextField.text = destinationAddress
//        amountTextField.text = amountInString
//    }
//
//    private func setMainParams(tokens: [ERC20TokenModel], wallet: WalletModel, utxos: [PlasmaUTXOs]) {
//        self.tokenDropdownManager?.tokens = tokens
//        self.tokenDropdownManager?.wallet = wallet
//        self.tokenDropdownManager?.utxos = utxos
//    }
//
//    private func setTableView(withManager manager: ManagerType, isPlasma: Bool) {
//        DispatchQueue.main.async { [weak self] in
//            let tableView = (manager == .Wallets ? self?.walletsDropdownTableView : self?.tokensDropdownTableView)!
//            let cellToRegister = manager == .Wallets ? "WalletCellDropdown" : "TokenCellDropdown"
//            let nib = UINib(nibName: cellToRegister, bundle: nil)
//            tableView.register(nib, forCellReuseIdentifier: cellToRegister)
//            tableView.delegate = manager == .Wallets ? self?.walletDropdownManager : self?.tokenDropdownManager
//            tableView.dataSource = manager == .Wallets ? self?.walletDropdownManager : self?.tokenDropdownManager
//
//            self?.walletDropdownManager?.isPlasma = isPlasma
//            self?.walletDropdownManager?.delegate = self
//            self?.tokenDropdownManager?.isPlasma = isPlasma
//            self?.tokenDropdownManager?.delegate = self
//
//            tableView.reloadData()
//        }
//    }
//
//    func addGestureRecognizer() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFrom))
//        addressFromLabel.addGestureRecognizer(tap)
//        addressFromLabel.isUserInteractionEnabled = true
//        let tokenTap = UITapGestureRecognizer(target: self, action: #selector(didTapToken))
//        tokenNameLabel.addGestureRecognizer(tokenTap)
//        tokenNameLabel.isUserInteractionEnabled = true
//    }
//
//    // MARK: - Dropdown
//    @objc func didTapFrom() {
//        let transform = self.heightWalletsConstraint.constant > 0 ?
//            CGAffineTransform.identity :
//            CGAffineTransform(rotationAngle: .pi)
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            self?.arrowDownWalletsImageView.transform = transform
//        }
//        if blockchainState == .ETH {
//            prepareDropdownViewForEtherBlockchain(withManager: .Wallets)
//        } else {
//            prepareDropdownViewForPlasmaBlockchain(withManager: .Wallets)
//        }
//        self.heightWalletsConstraint.constant = self.heightWalletsConstraint.constant > 0 ? 0 : 100
//        UIView.animate(withDuration: 1) { [weak self] in
//            self?.view.layoutIfNeeded()
//        }
//    }
//
//    @objc func didTapToken() {
//        let transform = self.heightTokensConstraint.constant > 0 ?
//            CGAffineTransform.identity :
//            CGAffineTransform(rotationAngle: .pi)
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            self?.arrowDownTokensImageView.transform = transform
//        }
//        if blockchainState == .ETH {
//            prepareDropdownViewForEtherBlockchain(withManager: .Tokens)
//        } else {
//            prepareDropdownViewForPlasmaBlockchain(withManager: .Tokens)
//        }
//        heightTokensConstraint.constant = heightTokensConstraint.constant > 0 ? 0 : 100
//        UIView.animate(withDuration: 0.5, animations: { [weak self] in
//            self?.view.layoutIfNeeded()
//        }, completion: nil)
//    }
//
//    func prepareDropdownViewForEtherBlockchain(withManager manager: ManagerType) {
//        tokenDropdownManager = TokenDropdownManager()
//        walletDropdownManager = WalletDropdownManager()
//        DispatchQueue.global().async { [weak self] in
//            switch manager {
//            case .Tokens:
//                guard let wallet = self?.wallet else {
//                    Alerts().showErrorAlert(for: self!, error: Errors.CommonErrors.unknown, completion: {})
//                    return
//                }
//                guard let tokens = try? TokensService().getAllTokens(for: wallet, networkId: CurrentNetwork().getNetworkID()) else {
//                    Alerts().showErrorAlert(for: self!, error: Errors.CommonErrors.unknown, completion: {})
//                    return
//                }
//                self?.setMainParams(tokens: tokens, wallet: wallet, utxos: [])
//            case .Wallets:
//                guard let wallets = try? self?.localStorage.getAllWallets(), let w = wallets else {
//                    Alerts().showErrorAlert(for: self!, error: Errors.CommonErrors.unknown, completion: {})
//                    return
//                }
//                self?.walletDropdownManager?.wallets = w
//            }
//            self?.setTableView(withManager: manager, isPlasma: false)
//        }
//    }
//
//    func getUTXOs() {
//        self.animation.waitAnimation(isEnabled: true, notificationText: "Getting UTXOs from Plasma", on: self.view)
//        currentUTXOs = []
//        let network = CurrentNetwork.currentNetwork
//        guard let wallet = self.wallet else {
//            return
//        }
//        guard let ethAddress = EthereumAddress(wallet.address) else {return}
//        let mainnet = network.chainID == Networks.Mainnet.chainID
//        let testnet = !mainnet && network.chainID == Networks.Rinkeby.chainID
//        if !testnet && !mainnet {return}
//        DispatchQueue.global().async { [weak self] in
//            do {
//                let list = try PlasmaService().getUTXOs(for: ethAddress, onTestnet: testnet)
//                self?.currentUTXOs = list
//                self?.animation.waitAnimation(isEnabled: false, notificationText: "Getting UTXOs from Plasma", on: (self?.view)!)
//            } catch {
//                self?.currentUTXOs = []
//                self?.animation.waitAnimation(isEnabled: false, notificationText: "Getting UTXOs from Plasma", on: (self?.view)!)
//            }
//        }
//    }
//
//    func prepareDropdownViewForPlasmaBlockchain(withManager manager: ManagerType) {
//        tokenDropdownManager = TokenDropdownManager()
//        walletDropdownManager = WalletDropdownManager()
//        DispatchQueue.global().async { [weak self] in
//            switch manager {
//            case .Tokens:
//                guard let wallet = self?.wallet,
//                    let utxos = self?.currentUTXOs else {
//                    return
//                }
//                self?.setMainParams(tokens: [], wallet: wallet, utxos: utxos)
//            case .Wallets:
//                guard let wallets = try? self?.localStorage.getAllWallets(), let w = wallets else {
//                    return
//                }
//                self?.walletDropdownManager?.wallets = w
//            }
//            self?.setTableView(withManager: manager, isPlasma: true)
//        }
//    }
//
//    // MARK: QR Code scan
//    lazy var readerVC: QRCodeReaderViewController = {
//
//        let builder = QRCodeReaderViewControllerBuilder {
//            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
//            $0.showSwitchCameraButton = false
//        }
//
//        return QRCodeReaderViewController(builder: builder)
//    }()
//
//    @IBAction func scanQR(_ sender: UIButton) {
//        readerVC.delegate = self
//        readerVC.modalPresentationStyle = .formSheet
//        present(readerVC, animated: true, completion: nil)
//    }
//
//    func prepareTransation(withPassword: String?) {
//
//        guard let amount = amountTextField.text,
//              let destinationAddress = enterAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//
//        guard let token = token else {return}
//
//        do {
//            if token == ERC20TokenModel(isEther: true) && destinationAddress == PlasmaContract.plasmaAddress {
//                let transaction = try self.transactionsService.prepareWriteContractTx(contractABI: PlasmaContract.plasmaABI,
//                                                                                      contractAddress: PlasmaContract.plasmaAddress,
//                                                                                      contractMethod: "deposit",
//                                                                                      value: amount,
//                                                                                      gasLimit: .automatic,
//                                                                                      gasPrice: .automatic,
//                                                                                      parameters: [AnyObject](),
//                                                                                      extraData: Data())
//                self.transactionOperation(isContract: true,
//                                          transaction: transaction,
//                                          amount: amount,
//                                          destinationAddress: destinationAddress,
//                                          password: withPassword)
//            } else if token == ERC20TokenModel(isEther: true) {
//                let transaction = try self.transactionsService.prepareSendEthTx(toAddress: destinationAddress,
//                                                                                 value: amount,
//                                                                                 gasLimit: .automatic,
//                                                                                 gasPrice: .automatic)
//                self.transactionOperation(transaction: transaction,
//                                          amount: amount,
//                                          destinationAddress: destinationAddress,
//                                          password: withPassword)
//            } else {
//                let transaction = try self.transactionsService.prepareSendERC20Tx(tokenAddress: token.address,
//                                                                                   toAddress: destinationAddress,
//                                                                                   tokenAmount: amount,
//                                                                                   gasLimit: .automatic,
//                                                                                   gasPrice: .automatic)
//                self.transactionOperation(transaction: transaction,
//                                          amount: amount,
//                                          destinationAddress: destinationAddress,
//                                          password: withPassword)
//            }
//        } catch let error {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: error, completion: {})
//        }
//    }
//
//    func transactionOperation(isContract: Bool = false, transaction: WriteTransaction, amount: String, destinationAddress: String, password: String?) {
//        DispatchQueue.main.async { [weak self] in
//            guard let name = self?.wallet?.name else {
//                return
//            }
//            let gasPrice = transaction.transactionOptions.gasPrice ?? .automatic
//            let gasLimit = transaction.transactionOptions.gasLimit ?? .automatic
//            let dict: [String: Any] = [
//                "gasPrice": gasPrice,
//                "gasLimit": gasLimit,
//                "transaction": transaction,
//                "amount": amount,
//                "name": name,
//                "fromAddress": self?.wallet?.address ?? "",
//                "toAddress": destinationAddress]
//
//            //self?.sendFunds(dict: dict, enteredPassword: withPassword)
//            self?.animation.waitAnimation(isEnabled: false,
//                                          on: (self?.view)!)
//            Alerts().showAccessAlert(for: self!,
//                                     with: "Send the transaction?",
//                                     completion: { [weak self] (result) in
//                if result {
//                    self?.enterPincode(for: dict,
//                                       isContract: isContract,
//                                       withPassword: password)
//                } else {
//                    Alerts().showErrorAlert(for: self!,
//                                            error: Errors.CommonErrors.unknown,
//                                            completion: {})
//                }
//            })
//        }
//    }
//
//    @IBAction func send(_ sender: UIButton) {
//        guard let wallet = wallet else {
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        if blockchainState == .ETH {
//            guard let token = token else {
//                return
//            }
//            animation.waitAnimation(isEnabled: true,
//                                    notificationText: "Preparing transaction",
//                                    on: self.view)
//            DispatchQueue.global().async { [weak self] in
//                do {
//                    try self?.localStorage.selectWallet(wallet: wallet)
//                    CurrentToken.currentToken = token
//                    self?.checkPassword { [weak self] (password) in
//                        self?.prepareTransation(withPassword: password)
//                    }
//                } catch let error {
//                    Alerts().showErrorAlert(for: self!, error: error, completion: {})
//                }
//            }
//        } else {
//            animation.waitAnimation(isEnabled: true,
//                                    notificationText: "Preparing transaction",
//                                    on: self.view)
//            DispatchQueue.global().async { [weak self] in
//                self?.checkPassword { [weak self] (password) in
//                    self?.preparePlasmaTransaction(withPassword: password)
//                }
//            }
//        }
//    }
//
//    func preparePlasmaTransaction(withPassword: String?) {
//        guard let utxo = utxo else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        guard let input = try? utxo.toTransactionInput() else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        let inputs = [input]
//
//        guard let amount = amountTextField.text,
//            let destinationAddress = enterAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        guard let floatAmount = Float(amount) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        let uintAmount = BigUInt( floatAmount * 1000000 )
//        let amountSendInETH = uintAmount * BigUInt(1000000000000)
//        let amountStayInETH = input.amount - amountSendInETH
//
//        guard let ethDestinationAddress = EthereumAddress(destinationAddress) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        guard let currentAddress = wallet?.address else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        guard let ethCurrentAddress = EthereumAddress(currentAddress) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//
//        guard let output1 = try? TransactionOutput(outputNumberInTx: 0,
//                                             receiverEthereumAddress: ethDestinationAddress,
//                                             amount: amountSendInETH) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//        guard let output2 = try? TransactionOutput(outputNumberInTx: 1,
//                                              receiverEthereumAddress: ethCurrentAddress,
//                                              amount: amountStayInETH) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Errors.CommonErrors.unknown, completion: {})
//            return
//        }
//
//        let outputs = [output1, output2]
//
//        guard let transaction = try? PlasmaTransaction(txType: .split, inputs: inputs, outputs: outputs) else {
//            self.animation.waitAnimation(isEnabled: false,
//                                         notificationText: "Preparing transaction",
//                                         on: self.view)
//            Alerts().showErrorAlert(for: self, error: Web3Error.transactionSerializationError, completion: {
//            })
//            return
//        }
//        Alerts().showAccessAlert(for: self, with: "Send the transaction?", completion: { [weak self] (result) in
//            if result {
//                self?.animation.waitAnimation(isEnabled: false,
//                                             notificationText: "Preparing transaction",
//                                             on: (self?.view)!)
//                self?.enterPincode(for: transaction, withPassword: withPassword)
//            } else {
//                self?.animation.waitAnimation(isEnabled: false,
//                                             notificationText: "Preparing transaction",
//                                             on: (self?.view)!)
//                Alerts().showErrorAlert(for: self!, error: Web3Error.transactionSerializationError, completion: {})
//            }
//        })
//    }
//
//    func checkPassword(completion: @escaping (String?) -> Void) {
//        do {
//            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
//                    account: "\(self.wallet?.name ?? "")-password",
//                    accessGroup: KeychainConfiguration.accessGroup)
//            let keychainPassword = try passwordItem.readPassword()
//            completion(keychainPassword)
//        } catch {
//            completion(nil)
//        }
//    }
//
//    func enterPincode(for data: [String: Any]?, isContract: Bool = false, withPassword: String?) {
//        guard let data = data else {
//            Alerts().showErrorAlert(for: self, error: Errors.NetworkErrors.noData, completion: {})
//            return
//        }
//        let enterPincode = EnterPincodeViewController(from: .transaction,
//                                                      for: data,
//                                                      isContract: isContract,
//                                                      withPassword: withPassword ?? "",
//                                                      isFromDeepLink: isFromDeepLink)
//        self.navigationController?.pushViewController(enterPincode, animated: true)
//    }
//
//    func enterPincode(for transaction: PlasmaTransaction, withPassword: String?) {
//        let enterPincode = EnterPincodeViewController(from: .transaction,
//                                                      for: transaction,
//                                                      withPassword: withPassword ?? "",
//                                                      isFromDeepLink: isFromDeepLink)
//        self.navigationController?.pushViewController(enterPincode, animated: true)
//    }
//
//    @IBAction func closeAction(_ sender: UIButton) {
//        let startViewController = AppController().goToApp()
//        startViewController.view.backgroundColor = UIColor.white
//        UIApplication.shared.keyWindow?.rootViewController = startViewController
//    }
//
//    @IBAction func changeBlockchain(_ sender: UISegmentedControl) {
//        currentUTXOs = []
//        if sender.selectedSegmentIndex == 0 {
//            blockchainState = .ETH
//            tokenNameLabel.text = token?.symbol.uppercased() ?? "ETH"
//        } else {
//            blockchainState = .Plasma
//            tokenNameLabel.text = "Choose UTXO"
//            self.getUTXOs()
//        }
//    }
//}
//
//// MARK: Dropdowns Delegates
//extension SendSettingsViewController: WalletSelectionDelegate, TokenSelectionDelegate {
//    func didSelectUTXO(utxo: PlasmaUTXOs) {
//        let balance = Web3Utils.formatToEthereumUnits(utxo.value,
//                                                      toUnits: .eth,
//                                                      decimals: 6,
//                                                      decimalSeparator: ".")
//        self.tokenNameLabel.text = balance
//        self.utxo = utxo
//        self.heightTokensConstraint.constant = 0
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//        }
//    }
//
//    func didSelectWallet(wallet: WalletModel) {
//        self.wallet = wallet
//        DispatchQueue.global().async { [weak self] in
//            do {
//                try self?.localStorage.selectWallet(wallet: wallet)
//                DispatchQueue.main.async {
//                    self?.addressFromLabel.text = wallet.address
//                    self?.heightWalletsConstraint.constant = 0
//                    UIView.animate(withDuration: 0.5, animations: { [weak self] in
//                        self?.view.layoutIfNeeded()
//                        }, completion: nil)
//                }
//                if self?.blockchainState == .Plasma {
//                    self?.getUTXOs()
//                }
//            } catch let error {
//                Alerts().showErrorAlert(for: self!, error: error, completion: {})
//            }
//        }
//    }
//
//    func didSelectToken(token: ERC20TokenModel) {
//        DispatchQueue.main.async {
//            self.tokenNameLabel.text = token.symbol.uppercased()
//            self.token = token
//            CurrentToken.currentToken = token
//            self.heightTokensConstraint.constant = 0
//            UIView.animate(withDuration: 0.5, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//        }
//    }
//}
//
//// MARK: QRCodeReaderViewController Delegate Methods
//extension SendSettingsViewController: QRCodeReaderViewControllerDelegate {
//    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
//        reader.stopScanning()
//        let value = result.value
//
//        if let parsed = Web3.EIP67CodeParser.parse(value) {
//            enterAddressTextField.text = parsed.address.address
//            if let amount = parsed.amount {
//                if token != ERC20TokenModel(isEther: true) {
//                    token = ERC20TokenModel(name: "", address: "", decimals: "", symbol: "")
//                }
//                amountTextField.text = Web3.Utils.formatToEthereumUnits(
//                        amount,
//                        toUnits: .eth,
//                        decimals: 4)
//            }
//        } else {
//            if EthereumAddress(value) != nil {
//                enterAddressTextField.text = value
//            }
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//
//    func readerDidCancel(_ reader: QRCodeReaderViewController) {
//        reader.stopScanning()
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: TextField Delegate
//extension SendSettingsViewController: UITextFieldDelegate {
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        textField.returnKeyType = sendButton.isEnabled ? UIReturnKeyType.done : .next
//        textField.textColor = UIColor.black
//        return true
//    }
//
//    private func isSendButtonEnabled(afterChanging textField: UITextField, with string: String) -> Bool {
//        var hardExpression = true
//        if blockchainState == .Plasma {
//            guard let utxo = utxo else {return false}
//            let balance = Web3Utils.formatToEthereumUnits(utxo.value,
//                                                          toUnits: .eth,
//                                                          decimals: 6,
//                                                          decimalSeparator: ".")
//            if textField != amountTextField {
//                let amount = Float(amountTextField.text ?? "0.0") ?? 0.0
//                hardExpression = hardExpression
//                    && !string.isEmpty
//                    && (wallet != nil)
//                    && !(amountTextField.text?.isEmpty ?? true)
//                    && (amount > Float(0))
//                    && (amount <= Float(balance ?? "0.0") ?? 0.0)
//            } else {
//                let amount = Float(string) ?? 0.0
//                hardExpression = hardExpression
//                    && !string.isEmpty
//                    && (wallet != nil)
//                    && (amount > Float(0))
//                    && (amount <= Float(balance ?? "0.0") ?? 0.0)
//                    && enterAddressTextField.text != nil
//            }
//        } else {
//            hardExpression = hardExpression && !string.isEmpty
//                && token != nil && wallet != nil
//                && Double(tokenBalance ?? "0") ?? 0.0 > Double(0)
//            let balance = Float(tokenBalance ?? "0") ?? 0.0
//            if textField != amountTextField {
//                let amount = (Float(amountTextField.text ?? "0.0") ?? 0.0)
//                hardExpression = hardExpression
//                    && !(amountTextField.text?.isEmpty ?? true)
//                    && amount > Float(0)
//                    && amount <= balance
//            } else {
//                hardExpression = hardExpression
//                    && Float(string) ?? 0.0 > Float(0)
//                    && Float(string) ?? 0.0 <= balance
//            }
//        }
//        return hardExpression
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentText = (textField.text ?? "") as NSString
//        let futureString = currentText.replacingCharacters(in: range, with: string) as String
//        hideSendButton(true)
//
//        let hardExpression = isSendButtonEnabled(afterChanging: textField, with: futureString)
//
//        hideSendButton(!hardExpression)
//
//        textField.returnKeyType = sendButton.isEnabled ? UIReturnKeyType.done : .next
//
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.returnKeyType == .done && sendButton.isEnabled {
//            animation.waitAnimation(isEnabled: true,
//                                    notificationText: "Preparing transaction",
//                                    on: self.view)
//            checkPassword { [weak self] (password) in
//                self?.prepareTransation(withPassword: password)
//            }
//        } else if textField.returnKeyType == .next {
//            let index = textFields.index(of: textField) ?? 0
//            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
//            textFields[nextIndex].becomeFirstResponder()
//        } else {
//            view.endEditing(true)
//        }
//        return true
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//        textField.textColor = UIColor.darkText
//
//        if textField == amountTextField {
//            guard Float(amountTextField.text ?? "") != nil else {
//                amountTextField.textColor = UIColor.red
//                return true
//            }
//        }
//        if textField == gasLimitTextField {
//            guard Int(gasLimitTextField.text ?? "") != nil else {
//                gasLimitTextField.textColor = UIColor.red
//                return true
//            }
//            guard Int((gasLimitTextField.text ?? "0"))! < 21000 else {
//                gasLimitTextField.text = "21000"
//                return true
//            }
//            guard Int((gasLimitTextField.text ?? "0"))! > 5 else {
//                gasLimitTextField.text = "5"
//                return true
//            }
//        }
//        if textField == gasPriceTextField {
//            guard Int(gasPriceTextField.text ?? "") != nil else {
//                gasPriceTextField.textColor = UIColor.red
//                return true
//            }
//            guard Int((gasPriceTextField.text ?? "0"))! < 100 else {
//                gasPriceTextField.text = "100"
//                return true
//            }
//            guard Int((gasPriceTextField.text ?? "0"))! > 5 else {
//                gasPriceTextField.text = "5"
//                return true
//            }
//        }
//        return true
//    }
//}
