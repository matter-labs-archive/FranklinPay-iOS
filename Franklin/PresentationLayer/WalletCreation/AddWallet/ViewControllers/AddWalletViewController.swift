//
//  AddWalletViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AddWalletViewController: BasicViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var settingUp: UILabel!
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var importWallet: BasicWhiteButton!
    @IBOutlet weak var createWallet: BasicGreenButton!
    @IBOutlet weak var animationImageView: UIImageView!

    // MARK: - Internal lets
    
    internal let navigationItems = NavigationItems()
    internal let walletCreating = WalletCreating()
    internal let appController = AppController()
    internal let alerts = Alerts()
    internal var walletCreated = false
    
    // MARK: - Weak vars
    
    weak var animationTimer: Timer?
    
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
        //additionalSetup()
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
    
//    func additionalSetup() {
//        self.topViewForModalAnimation.blurView()
//        self.topViewForModalAnimation.alpha = 0
//        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
//        self.topViewForModalAnimation.isUserInteractionEnabled = false
//        self.view.addSubview(topViewForModalAnimation)
//    }
    
    func createView() {
        animationImageView.setGifImage(UIImage(gifName: "loading.gif"))
        animationImageView.loopCount = -1
        
        self.parent?.view.backgroundColor = .white
        
        prodName.text = Constants.prodName
        prodName.textAlignment = .center
        prodName.textColor = Colors.textDarkGray
        prodName.font = UIFont(name: Constants.Fonts.franklinSemibold, size: 55) ?? UIFont.boldSystemFont(ofSize: 55)
        
        subtitle.textAlignment = .center
        subtitle.text = Constants.slogan
        subtitle.textColor = Colors.textDarkGray
        subtitle.font = UIFont(name: Constants.Fonts.franklinMedium, size: 22) ?? UIFont.systemFont(ofSize: 22)
        
        settingUp.textAlignment = .center
        settingUp.text = "Setting up your wallet"
        settingUp.textColor = Colors.textDarkGray
        settingUp.font = UIFont(name: Constants.Fonts.regular, size: 24) ?? UIFont.systemFont(ofSize: 24)
        
        animationImageView.frame = CGRect(x: 0, y: 0, width: 0.8*UIScreen.main.bounds.width, height: 257)
        animationImageView.contentMode = .center
        animationImageView.alpha = 0
        animationImageView.isUserInteractionEnabled = false
        
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "franklin")!
        
        settingUp.alpha = 0
        
        importWallet.addTarget(self,
                                 action: #selector(importAction(sender:)),
                                 for: .touchUpInside)
        importWallet.setTitle("Import Wallet", for: .normal)
        importWallet.alpha = 1
        
        createWallet.addTarget(self,
                               action: #selector(createAction(sender:)),
                               for: .touchUpInside)
        createWallet.setTitle("Create Wallet", for: .normal)
        createWallet.alpha = 1
        
        //        link.addTarget(self, action: #selector(readTerms(sender:)), for: .touchUpInside)
        
    }
    
    // MARK: - Actions
    
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
            walletCreated = true
            if animationTimer == nil {
                goToApp()
            }
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
    
    @objc func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
                self.view.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let tabViewController = self.appController.goToApp()
                    tabViewController.view.backgroundColor = Colors.background
                    let transition = CATransition()
                    transition.duration = Constants.Main.animationDuration
                    transition.type = CATransitionType.push
                    transition.subtype = CATransitionSubtype.fromRight
                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(tabViewController, animated: false, completion: nil)
                })
            }
        }
    }
    
    // MARK: - Buttons actions
    
    @objc func createAction(sender: UIButton) {
        createWallet.isUserInteractionEnabled = false
        importWallet.isUserInteractionEnabled = false
        animation()
        creatingWallet()
    }
    
    @objc func importAction(sender: UIButton) {
        let vc = WalletImportingViewController()
//        vc.delegate = self
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.view.layer.speed = Constants.ModalView.animationSpeed
//        self.present(vc, animated: true, completion: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Animations
    
    func animation() {
        navigationController?.navigationBar.isHidden = true
        animationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
        animateIndicator()
    }
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        if walletCreated {
            goToApp()
        }
    }
    
    func animateIndicator() {
        UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
            self.createWallet.alpha = 0
            self.importWallet.alpha = 0
            self.animationImageView.alpha = 1
            self.settingUp.alpha = 1
        }
    }
    
//    func modalViewBeenDismissed(updateNeeded: Bool) {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = 0
//            })
//        }
//    }
//
//    func modalViewAppeared() {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
//            })
//        }
//    }

}
