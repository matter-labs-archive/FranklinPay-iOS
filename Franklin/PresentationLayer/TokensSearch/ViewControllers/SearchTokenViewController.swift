//
//  SearchTokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader

class SearchTokenViewController: BasicViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var searchTextField: BasicTextField!
    @IBOutlet weak var tokensTableView: BasicTableView!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addButton: BasicBlueButton!
    
    // MARK: - Internal vars
    
    internal var ratesUpdating = false

    internal var tokensList: [ERC20Token] = []
    internal var tokensForDeleting: Set<ERC20Token> = []
    internal var tokensForAdding: Set<ERC20Token> = []
    internal var tokensAreAdded: [Bool] = []

    internal  var searchController: UISearchController!
    internal var wallet: Wallet?

    internal let tokensService = TokensService()
    internal let alerts = Alerts()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeHelpLabel(enabled: true)
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
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
    
    // MARK: - Buttons actions
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func addAction(_ sender: BasicBlueButton) {
        tokensForAdding.removeAll()
        tokensForDeleting.removeAll()
        dismissView()
    }
    
    @objc func dismissView() {
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
