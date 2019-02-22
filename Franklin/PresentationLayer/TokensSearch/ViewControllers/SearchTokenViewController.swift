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
    
    // MARK: - Internal vars
    
    internal var ratesUpdating = false

    internal var tokensList: [ERC20Token] = []
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
        self.view.backgroundColor = Colors.background
        self.hideKeyboardWhenTappedAround()
        self.setupNavigation()
        self.setupTableView()
        self.mainSetup()
        self.setupSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        makeHelpLabel(enabled: true)
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        self.contentView.backgroundColor = Colors.background
        self.contentView.alpha = 1
        self.contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        self.contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        self.contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
    }
    
    func setupSearch() {
        searchTextField.delegate = self
        definesPresentationContext = true
    }
    
    func setupNavigation() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupTableView() {
        self.tokensTableView.delegate = self
        self.tokensTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        self.tokensTableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: "SearchTokenCell", bundle: nil)
        self.tokensTableView.register(nibSearch, forCellReuseIdentifier: "SearchTokenCell")
        let nibAddress = UINib.init(nibName: "AddressTableViewCell", bundle: nil)
        self.tokensTableView.register(nibAddress, forCellReuseIdentifier: "AddressTableViewCell")
    }
    
    // MARK: - Actions
    
    func clearData() {
        self.tokensList.removeAll()
        self.tokensAreAdded.removeAll()
    }
    
    func searchTokens(string: String) {
        DispatchQueue.global().async { [unowned self] in
            guard let list = try? self.tokensService.getFullTokensList(for: string) else {
                self.emptyTokensList()
                return
            }
            self.updateTokensList(with: list, completion: {
                self.reloadTableData()
//                self.updateRates {
//                    self.reloadTableDataWithDelay()
//                }
            })
        }
    }
    
//    func updateRates(comletion: @escaping () -> Void) {
//        guard !self.ratesUpdating else { return }
//        self.ratesUpdating = true
//        let first10List: [ERC20Token]
//        if self.tokensList.count > 10 {
//            first10List = Array(self.tokensList.prefix(upTo: 10))
//        } else {
//            first10List = self.tokensList
//        }
//        for token in first10List {
//            do {
//                _ = try token.updateRateAndChange()
//            } catch {
//                continue
//            }
//        }
//        self.ratesUpdating = false
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
        self.dismissView()
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: true)
    }
    
    @objc func scanTapped() {
        readerVC.delegate = self
        self.readerVC.modalPresentationStyle = .formSheet
        self.present(readerVC, animated: true)
    }
    
    @objc func textFromBuffer() {
        if let string = UIPasteboard.general.string {
            self.searchTextField.text = string
            //            DispatchQueue.main.async { [weak self] in
            //                self?.searchBar(searchBar, textDidChange: string)
            //            }
        }
    }
}
