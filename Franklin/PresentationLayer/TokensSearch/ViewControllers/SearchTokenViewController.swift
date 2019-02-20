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

    @IBOutlet weak var searchTextField: BasicTextField!
    @IBOutlet weak var tokensTableView: BasicTableView!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var ratesUpdating = false

    var tokensList: [ERC20Token] = []
    var tokensAreAdded: [Bool] = []

    var searchController: UISearchController!

    var wallet: Wallet?

    let tokensService = TokensService()
    let alerts = Alerts()
    
    weak var delegate: ModalViewDelegate?

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()

    convenience init(for wallet: Wallet) {
        self.init()
        self.wallet = wallet
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.background
        self.hideKeyboardWhenTappedAround()
        self.setupNavigation()
        self.setupTableView()
        self.mainSetup()
        self.setupSearch()
    }
    
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
    
    func clearData() {
        self.tokensList.removeAll()
        self.tokensAreAdded.removeAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        makeHelpLabel(enabled: true)
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
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: true)
    }
}

extension SearchTokenViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tokensList.isEmpty {
            return 1
        } else {
            return tokensList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tokensList.isEmpty {
            return CGFloat(Constants.TableCells.Heights.additionalButtons)
        } else {
            return CGFloat(Constants.TableCells.Heights.tokensSearch)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !tokensList.isEmpty {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTokenCell",
                                                           for: indexPath) as? SearchTokenCell else {
                return UITableViewCell()
            }

            cell.configure(with: tokensList[indexPath.row], isAdded: tokensAreAdded[indexPath.row])
            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell",
                                                           for: indexPath) as? AddressTableViewCell else {
                                                            return UITableViewCell()
            }
            cell.qr.addTarget(self, action: #selector(self.scanTapped), for: .touchUpInside)
            cell.paste.addTarget(self, action: #selector(self.textFromBuffer), for: .touchUpInside)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is AddressTableViewCell {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let token = self.tokensList[indexPath.row]
        let isAdded = tokensAreAdded[indexPath.row]
        guard let wallet = self.wallet else {
            return
        }
        do {
            if isAdded {
                try wallet.delete(token: token, network: CurrentNetwork.currentNetwork)
                tokensAreAdded[indexPath.row] = false
                CurrentToken.currentToken = Ether()
            } else {
                try wallet.add(token: token, network: CurrentNetwork.currentNetwork)
                tokensAreAdded[indexPath.row] = true
            }
            self.reloadTableData()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchTokenViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string) as String
        if newText == "" {
            emptyTokensList()
            makeHelpLabel(enabled: true)
        } else {
            let token = newText
            makeHelpLabel(enabled: false)
            searchTokens(string: token)
        }
        return true
    }
}

extension SearchTokenViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let searchText = result.value.lowercased()
        self.searchTextField.text = searchText
        reader.dismiss(animated: true)
//        DispatchQueue.main.async { [weak self] in
//
//            self?.searchBar(searchBar, textDidChange: searchText)
//        }
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true)
    }
}
