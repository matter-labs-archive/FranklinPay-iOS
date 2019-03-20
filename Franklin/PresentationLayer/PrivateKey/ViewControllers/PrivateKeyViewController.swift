//
//  PrivateKeyViewController.swift
//  Franklin
//
//  Created by Anton on 12/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

class PrivateKeyViewController: BasicViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var shareAddress: BasicBlueButton!
    @IBOutlet weak var copyAddress: BasicWhiteButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var privateKey: UILabel!
    
    // MARK: - Internal lets
    internal let alerts = Alerts()
    internal let navigationItems = NavigationItems()
    
    internal var pk: String = "" {
        didSet {
            privateKey.text = pk
            qrCode.image = generateQRCode(from: pk)
        }
    }
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        setNavigation(hidden: false)
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
        navigationItem.hidesBackButton = true
    }
    
    func mainSetup() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        contentView.backgroundColor = Colors.background
        contentView.alpha = 1
    }
    
    func setup() {
        guard let wallet = CurrentWallet.currentWallet, let password = try? wallet.getPassword(), let pk = try? wallet.getPrivateKey(withPassword: password) else {
            alerts.showErrorAlert(for: self, error: "Can't get private key for this wallet") { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        DispatchQueue.main.async { [unowned self] in
            self.pk = pk
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let code: String = string
        let data = code.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    // MARK: - Buttons actions
    
    @IBAction func copyAction(_ sender: UIButton) {
        UIPasteboard.general.string = privateKey.text
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        let addressToShare: String = pk
        
        let itemsToShare = [ addressToShare ]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.markupAsPDF ]
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
                self.view.hideSubviews()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                    self.setNavigation(hidden: true)
                    self.navigationController?.popToRootViewController(animated: true)
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
