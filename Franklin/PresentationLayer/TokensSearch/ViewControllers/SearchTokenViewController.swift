//
//  SearchTokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader
import EthereumAddress

class SearchTokenViewController: BasicViewController {
    
    // MARK: - Enums
    
    internal enum ScreenStatus {
        case search
        case customToken
    }
    
    internal enum TextFieldsTags: Int {
        case name = 0
        case address = 1
        case symbol = 2
        case decimals = 3
        case search = 4
    }
    
    // MARK: - Outlets

    @IBOutlet weak var searchTextField: BasicTextField!
    @IBOutlet weak var tokensTableView: BasicTableView!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addButton: BasicBlueButton!
    @IBOutlet weak var addCustomToken: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var customTokenView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tokenNameTextField: BasicTextField!
    @IBOutlet weak var tokenSymbolTextField: BasicTextField!
    @IBOutlet weak var tokenAddressTextField: BasicTextField!
    @IBOutlet weak var decimalsTextField: BasicTextField!
    @IBOutlet var tokenTextFields: [BasicTextField]!
    
    // MARK: - Internal vars
    
    internal var ratesUpdating = false

    internal var tokensList: [ERC20Token] = []
    internal var tokensForDeleting: Set<ERC20Token> = [] {
        didSet {
            makeConfirmButton(enabled: !tokensForAdding.isEmpty || !tokensForDeleting.isEmpty)
        }
    }
    internal var tokensForAdding: Set<ERC20Token> = [] {
        didSet {
            makeConfirmButton(enabled: !tokensForAdding.isEmpty || !tokensForDeleting.isEmpty)
        }
    }
    internal var tokensAreAdded: [Bool] = []

    internal  var searchController: UISearchController!
    internal var wallet: Wallet?

    internal let tokensService = TokensService()
    internal let alerts = Alerts()
    
    internal var currentScreen: ScreenStatus = .search {
        didSet {
            switch currentScreen {
            case .search:
                addCustomToken.setTitle("Create", for: .normal)
                titleLabel.text = "Search tokens"
                makeConfirmButton(enabled: !tokensForAdding.isEmpty || !tokensForDeleting.isEmpty)
                makeSearchView(enabled: true)
                makeCustomTokenView(enabled: false)
            case .customToken:
                addCustomToken.setTitle("Back", for: .normal)
                titleLabel.text = "Add custom token"
                makeConfirmButton(enabled: areTokenFieldsFilled())
                makeSearchView(enabled: false)
                makeCustomTokenView(enabled: true)
            }
        }
    }
    
    // MARK: - weak vars
    
    weak var delegate: ModalViewDelegate?
    
    // MARK: - lazy vars

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Inits

    convenience init(for wallet: Wallet) {
        self.init()
        self.wallet = wallet
    }
    
    // MARK: - Lifesycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        hideKeyboardWhenTappedAround()
        setupNavigation()
        setupTableView()
        mainSetup()
        setupSearch()
        setupTokenTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeConfirmButton(enabled: false)
        makeHelpLabel(enabled: true)
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
        currentScreen = .search
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        addButton.setTitle("Confirm", for: .normal)
        
        contentView.backgroundColor = Colors.background
        contentView.alpha = 1
        contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
    }
    
    func setupSearch() {
        searchTextField.delegate = self
        definesPresentationContext = true
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupTableView() {
        tokensTableView.delegate = self
        tokensTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        tokensTableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: "SearchTokenCell", bundle: nil)
        tokensTableView.register(nibSearch, forCellReuseIdentifier: "SearchTokenCell")
        let nibAddress = UINib.init(nibName: "AddressTableViewCell", bundle: nil)
        tokensTableView.register(nibAddress, forCellReuseIdentifier: "AddressTableViewCell")
    }
    
    func setupTokenTextFields() {
        tokenNameTextField.delegate = self
        tokenAddressTextField.delegate = self
        decimalsTextField.delegate = self
        tokenSymbolTextField.delegate = self
        searchTextField.delegate = self
        
        tokenNameTextField.tag = TextFieldsTags.name.rawValue
        tokenAddressTextField.tag = TextFieldsTags.address.rawValue
        decimalsTextField.tag = TextFieldsTags.decimals.rawValue
        tokenSymbolTextField.tag = TextFieldsTags.symbol.rawValue
        searchTextField.tag = TextFieldsTags.search.rawValue
    }
    
    // MARK: - Actions
    
    func clearData() {
        tokensList.removeAll()
        tokensAreAdded.removeAll()
    }
    
    func searchTokens(string: String) {
        DispatchQueue.global().async { [unowned self] in
            guard let list = try? self.tokensService.getFullTokensList(for: string) else {
                self.emptyTokensList()
                return
            }
            self.updateTokensList(with: list, completion: {
                self.reloadTableData()
//                updateRates {
//                    reloadTableDataWithDelay()
//                }
            })
        }
    }
    
//    func updateRates(comletion: @escaping () -> Void) {
//        guard !ratesUpdating else { return }
//        ratesUpdating = true
//        let first10List: [ERC20Token]
//        if tokensList.count > 10 {
//            first10List = Array(tokensList.prefix(upTo: 10))
//        } else {
//            first10List = tokensList
//        }
//        for token in first10List {
//            do {
//                _ = try token.updateRateAndChange()
//            } catch {
//                continue
//            }
//        }
//        ratesUpdating = false
//        comletion()
//    }
    
    func makeHelpLabel(enabled: Bool) {
        helpLabel.alpha = enabled ? 1 : 0
    }
    
    func emptyTokensList() {
        clearData()
        reloadTableData()
    }
    
    func makeConfirmButton(enabled: Bool) {
        addButton.isEnabled = enabled
        addButton.alpha = enabled ? 1 : 0.5
    }
    
    func makeSearchView(enabled: Bool) {
        UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
            self.searchView.isHidden = !enabled
            self.searchView.isUserInteractionEnabled = enabled
        }
    }
    
    func makeCustomTokenView(enabled: Bool) {
        UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
            self.customTokenView.isHidden = !enabled
            self.customTokenView.isUserInteractionEnabled = enabled
        }
    }
    
    func areTokenFieldsFilled() -> Bool {
        let filled = !(tokenNameTextField.text?.isEmpty ?? true)
            && !(tokenAddressTextField.text?.isEmpty ?? true)
            && !(tokenSymbolTextField.text?.isEmpty ?? true)
            && !(decimalsTextField.text?.isEmpty ?? true)
        return filled
    }
    
    // MARK: - Table view updates
    
    func reloadTableData() {
        DispatchQueue.main.async { [unowned self] in
            self.tokensTableView.reloadData()
        }
    }
    
    func reloadTableDataWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [unowned self] in
            self.tokensTableView.reloadData()
        })
    }
    
    func updateTokensList(with list: [ERC20Token], completion: @escaping () -> Void) {
        clearData()
        let network = CurrentNetwork.currentNetwork
        if let wallet = wallet, let tokensInWallet = try? wallet.getAllTokens(network: network) {
            tokensList = list
            for tokenFromList in tokensList {
                var isAdded = false
                for tokenFromWallet in tokensInWallet where tokenFromList == tokenFromWallet {
                    isAdded = true
                }
                tokensAreAdded.append(isAdded)
            }
        }
        completion()
    }
    
    func addTokenWithResult() -> Bool {
        guard let name = tokenNameTextField.text,
            let address = tokenAddressTextField.text,
            let symbol = tokenSymbolTextField.text,
            let decimals = decimalsTextField.text else {
            alerts.showErrorAlert(for: self, error: "Can't get token info", completion: nil)
                return false
        }
        guard EthereumAddress(address) != nil else {
            alerts.showErrorAlert(for: self, error: "Wrong address", completion: nil)
            return false
        }
        let token = ERC20Token(name: name,
                               address: address,
                               decimals: decimals,
                               symbol: symbol)
        let net = CurrentNetwork.currentNetwork
        guard let wallet = CurrentWallet.currentWallet else {
            alerts.showErrorAlert(for: self, error: "Can't get wallet", completion: nil)
            return false
        }
        guard let tokenExists = try? wallet.isTokenExists(token: token, network: net) else {
            alerts.showErrorAlert(for: self, error: "Can't check token existance", completion: nil)
            return false
        }
        if tokenExists {
            alerts.showErrorAlert(for: self, error: "Token exists", completion: nil)
            return false
        }
        do {
            try wallet.add(token: token, network: net)
        } catch let error {
            alerts.showErrorAlert(for: self, error: "Can't save token: \(error.localizedDescription)", completion: nil)
        }
        return true
    }
    
    func deleteUnsavedTokens() {
        guard let wallet = wallet else {
            return
        }
        let net = CurrentNetwork.currentNetwork
        for token in tokensForAdding {
            do {
                try wallet.delete(token: token, network: net)
            } catch {
                return
            }
        }
        for token in tokensForDeleting {
            do {
                try wallet.add(token: token, network: net)
            } catch {
                return
            }
        }
    }
    
    func removeSavedTokens() {
        tokensForAdding.removeAll()
        tokensForDeleting.removeAll()
    }
    
    // MARK: - Buttons actions
    
    @IBAction func closeAction(_ sender: UIButton) {
        deleteUnsavedTokens()
        dismissView()
    }
    
    @IBAction func addAction(_ sender: BasicBlueButton) {
        if currentScreen == .customToken {
            if addTokenWithResult() {
                deleteUnsavedTokens()
                dismissView()
            }
        } else {
            removeSavedTokens()
            deleteUnsavedTokens()
            dismissView()
        }
    }
    
    @IBAction func changeScreenStatus(_ sender: UIButton) {
        switch currentScreen {
        case .search:
            currentScreen = .customToken
        case .customToken:
            currentScreen = .search
        }
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: true)
    }
    
    @objc func scanTapped() {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true)
    }
    
    @objc func textFromBuffer() {
        if let string = UIPasteboard.general.string {
            searchTextField.text = string
            //            DispatchQueue.main.async { [weak self] in
            //                self?.searchBar(searchBar, textDidChange: string)
            //            }
        }
    }
}
