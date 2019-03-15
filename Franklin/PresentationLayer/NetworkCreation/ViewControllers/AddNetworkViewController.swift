//
//  AddNetworkViewController.swift
//  Franklin
//
//  Created by Anton on 07/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class AddNetworkViewController: BasicViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var enterButton: BasicBlueButton!
    @IBOutlet var textFields: [BasicTextField]!
    @IBOutlet weak var nameTextField: BasicTextField!
    @IBOutlet weak var endpointTextField: BasicTextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Internal lets
    
    internal let networksService = NetworksService()
    internal let navigationItems = NavigationItems()
    internal let appController = AppController()
    internal let alerts = Alerts()
    internal let endpointValidator = EndpointValidator()
    internal let networkCreator = NetworkCreator()
    
    // MARK: - Enums
    
    enum TextFieldsTags: Int {
        case name = 0
        case endpoint = 1
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigation(hidden: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        additionalSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigation(hidden: true)
    }
    
    // MARK: - Main setup
    
    func setNavigation(hidden: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: true)
        navigationController?.makeClearNavigationController()
        let home = navigationItems.homeItem(target: self, action: #selector(goToApp))
        navigationItem.setRightBarButton(home, animated: false)
    }
    
    func createView() {
        mainSetup()
        setupTextFields()
    }
    
    func additionalSetup() {
        showLabels(true)
    }
    
    func mainSetup() {
        hideKeyboardWhenTappedAround()
        
        enterButton.isEnabled = false
        updateEnterButtonAlpha()
        
        contentView.backgroundColor = Colors.background
        contentView.alpha = 1
    }
    
    func showLabels(_ show: Bool) {
        nameLabel.alpha = show ? 1 : 0
        endpointLabel.alpha = show ? 1 : 0
        titleLabel.alpha = show ? 1 : 0
    }
    
    func setupTextFields() {
        nameTextField.delegate = self
        endpointTextField.delegate = self
        nameTextField.tag = TextFieldsTags.name.rawValue
        endpointTextField.tag = TextFieldsTags.endpoint.rawValue
        nameTextField.returnKeyType = .next
        endpointTextField.returnKeyType = .next
    }
    
    // MARK: - Screen updates
    
    internal func updateEnterButtonAlpha() {
        enterButton.alpha = enterButton.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Screen status
    
    internal func isEnterButtonEnabled(afterChanging textField: UITextField, with string: String) {
        enterButton.isEnabled = false
        let everyFieldIsOK: Bool
        switch textField {
        case endpointTextField:
            everyFieldIsOK = !(nameTextField.text?.isEmpty ?? true) && !string.isEmpty
        default:
            everyFieldIsOK = !(endpointTextField.text?.isEmpty ?? true) && !string.isEmpty
        }
        enterButton.isEnabled = everyFieldIsOK
    }
    
    // MARK: - Actions
    
    private func addNetwork(endpoint: String, name: String) {
        if let error = endpointValidator.checkEnpointForSemanticAndReturnError(endpoint: endpoint) {
            alerts.showErrorAlert(for: self, error: error, completion: nil)
        } else {
            guard let url = try? networkCreator.formEndpointURLString(fromString: endpoint) else {
                alerts.showErrorAlert(for: self, error: "Wrong URL string", completion: nil)
                return
            }
            let id = networksService.getHighestID() + 1
            let network = Web3Network(id: id,
                                      name: name,
                                      endpoint: url)
            let networkExists = networksService.isNetworkExistsInWallet(network: network)
            if networkExists {
                alerts.showErrorAlert(for: self, error: "Network exists", completion: nil)
                return
            }
            if !networkCreator.isNetworkPossible(network: network) {
                alerts.showErrorAlert(for: self, error: "Wrong URL", completion: nil)
                return
            }
            do {
                try network.save()
                CurrentNetwork.currentNetwork = network
                try networkCreator.addBaseTokenIfExists(forNetwork: network)
                goToApp()
            } catch {
                alerts.showErrorAlert(for: self, error: "Can't create network. Error: \(error)", completion: nil)
                return
            }
        }
    }
    
    @objc func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
                self.view.hideSubviews()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                    self.setNavigation(hidden: true)
                    self.navigationController?.popToRootViewController(animated: true)
                    //                    let tabViewController = appController.goToApp()
                    //                    tabViewController.view.backgroundColor = Colors.background
                    //                    let transition = CATransition()
                    //                    transition.duration = Constants.Main.animationDuration
                    //                    transition.type = CATransitionType.push
                    //                    transition.subtype = CATransitionSubtype.fromRight
                    //                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                    //                    view.window!.layer.add(transition, forKey: kCATransition)
                    //                    present(tabViewController, animated: false, completion: nil)
                })
            }
        }
    }
    
    // MARK: - Buttons actions
    
    @IBAction func addNetworkButtonTapped(_ sender: Any) {
        guard let endpoint = endpointTextField.text else {
            return
        }
        guard let name = nameTextField.text else {
            return
        }
        addNetwork(endpoint: endpoint, name: name)
    }
}
