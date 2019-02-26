//
//  AcceptChequeController.swift
//  Franklin
//
//  Created by Anton Grigorev on 28/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class AcceptChequeController: BasicViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Internal lets
    
    internal let cheque: PlasmaCode
    
    internal let appController = AppController()
    internal let walletCreating = WalletCreating()
    internal let walletsService = WalletsService()
    internal let alerts = Alerts()
    
    internal let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    // MARK: - Inits
    
    init(cheque: PlasmaCode) {
        self.cheque = cheque
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAcceptForm()
    }
    
    // MARK: - Main setup
    
    func setupNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func createView() {
        topViewForModalAnimation.blurView()
        topViewForModalAnimation.alpha = 0
        topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        topViewForModalAnimation.isUserInteractionEnabled = false
        
        view.addSubview(topViewForModalAnimation)
        
        titleLabel.alpha = 0
    }
    
    // MARK: - Actions
    
    func showAcceptForm() {
        modalViewAppeared()
        let acceptChequeForm = AcceptChequeFormController(cheque: cheque)
        acceptChequeForm.delegate = self
        acceptChequeForm.modalPresentationStyle = .overCurrentContext
        acceptChequeForm.view.layer.speed = Constants.ModalView.animationSpeed
        present(acceptChequeForm, animated: true, completion: nil)
    }
    
    func creatingWallet() {
        DispatchQueue.global().async { [unowned self] in
            do {
                let wallet = try self.walletCreating.createWallet()
                self.finishSavingWallet(wallet)
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: error, completion: nil)
            }
        }
    }
    
    func finishSavingWallet(_ wallet: Wallet) {
        do {
            try walletCreating.prepareWallet(wallet)
            CurrentWallet.currentWallet = wallet
        } catch let error {
            deleteWallet(wallet: wallet, withError: error)
        }
    }
    
    func deleteWallet(wallet: Wallet, withError error: Error) {
        do {
            try wallet.delete()
            alerts.showErrorAlert(for: self, error: error, completion: nil)
        } catch let deleteErr {
            alerts.showErrorAlert(for: self, error: deleteErr, completion: nil)
        }
    }
    
    func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) {
                self.view.hideSubviews()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                    let tabViewController = self.appController.goToApp()
                    //                        tabViewController.context
                    //                        tabViewController.view.backgroundColor = Colors.background
                    //                        let transition = CATransition()
                    //                        transition.duration = Constants.Main.animationDuration
                    //                        transition.type = CATransitionType.push
                    //                        transition.subtype = CATransitionSubtype.fromRight
                    //                        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                    //                        self.view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(tabViewController, animated: false, completion: nil)
//                    let tabViewController = self.appController.goToApp()
//                    tabViewController.view.backgroundColor = Colors.background
//                    let transition = CATransition()
//                    transition.duration = Constants.Main.animationDuration
//                    transition.type = CATransitionType.push
//                    transition.subtype = CATransitionSubtype.fromRight
//                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//                    self.view.window!.layer.add(transition, forKey: kCATransition)
//                    self.present(tabViewController, animated: false, completion: nil)
                })
            }
        }
    }
}
