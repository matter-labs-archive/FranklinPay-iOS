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
    @IBOutlet weak var animationImageView: UIImageView!
    
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
        
        animationImageView.setGifImage(UIImage(gifName: "loading.gif"))
        animationImageView.loopCount = -1
        animationImageView.frame = CGRect(x: 0, y: 0, width: 0.8*UIScreen.main.bounds.width, height: 257)
        animationImageView.contentMode = .center
        animationImageView.alpha = 0
        animationImageView.isUserInteractionEnabled = false
        
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
    
    // MARK: - Animation
    
    func animation() {
        //setNavigation(hidden: true)
        animateIndicator()
    }
    
    func cancelAnimation() {
        DispatchQueue.main.async { [unowned self] in
            self.enterButton.isUserInteractionEnabled = true
            UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
                //self.setNavigation(hidden: false)
                self.enterButton.alpha = 1
                self.animationImageView.alpha = 0
            }
        }
    }
    
    func animateIndicator() {
        UIView.animate(withDuration: Constants.Main.animationDuration) {
            self.enterButton.alpha = 0
            self.animationImageView.alpha = 1
        }
    }
    
    // MARK: - Actions
    
    private func addNetwork(endpoint: String, name: String) {
        let lowercasedURL = endpoint.lowercased()
        if let error = endpointValidator.checkEnpointForSemanticAndReturnError(endpoint: lowercasedURL) {
            alerts.showErrorAlert(for: self, error: error) { [unowned self] in
                self.cancelAnimation()
            }
        } else {
            guard let url = try? networkCreator.formEndpointURLString(fromString: lowercasedURL) else {
                alerts.showErrorAlert(for: self, error: "Wrong URL string") { [unowned self] in
                    self.cancelAnimation()
                }
                return
            }
            let id = networksService.getHighestID() + 1
            let network = Web3Network(id: id,
                                      name: name,
                                      endpoint: url)
            let networkExists = networksService.isNetworkExistsInWallet(network: network)
            if networkExists {
                alerts.showErrorAlert(for: self, error: "Network exists") { [unowned self] in
                    self.cancelAnimation()
                }
                return
            }
            if !networkCreator.isNetworkPossible(network: network) {
                alerts.showErrorAlert(for: self, error: "Wrong URL") { [unowned self] in
                    self.cancelAnimation()
                }
                return
            }
            do {
                try network.save()
                CurrentNetwork.currentNetwork = network
                try networkCreator.addBaseTokenIfExists(forNetwork: network)
                cancelAnimation()
                goToApp()
            } catch {
                alerts.showErrorAlert(for: self, error: "Can't create network. Error: \(error)") { [unowned self] in
                    self.cancelAnimation()
                }
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
        animation()
        DispatchQueue.global().async { [unowned self] in
            self.addNetwork(endpoint: endpoint, name: name)
        }
    }
}
