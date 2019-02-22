////
////  PrivateKeyViewController.swift
////  DiveLane
////
////  Created by NewUser on 13/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//import Web3swift
//
//class PrivateKeyViewController: BasicViewController {
//    @IBOutlet weak var privateQRimageView: UIImageView!
//    @IBOutlet weak var privateKeyLabel: UILabel!
//    @IBOutlet weak var notificationLabel: UILabel!
//
//    var wallet: Wallet
//    
//    var pk: String = "" {
//        didSet {
//            self.privateKeyLabel.text = pk
//            self.privateQRimageView.image = self.generateQRCode(from: pk)
//        }
//    }
//    
//    let alerts = Alerts()
//
//    init(for wallet: Wallet) {
//        self.wallet = wallet
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = Colors.textWhite
//        self.privateKeyLabel.textColor = Colors.textDarkGray
//        self.notificationLabel.textColor = Colors.mainGreen
//        self.setupNavigation()
//    }
//    
//    func setupNavigation() {
//        self.title = "Export private key"
//        let exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAddress(_:)))
//        self.navigationItem.rightBarButtonItem = exportButton
//    }
//    
//    @objc func shareAddress(_ sender : UIBarButtonItem) {
//        let addressToShare: String = pk
//        
//        let itemsToShare = [ addressToShare ]
//        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.markupAsPDF ]
//        self.present(activityViewController, animated: true, completion: nil)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.hideCopiedLabel(true)
//        self.setup()
//    }
//    
//    func setup() {
//        do {
//            let password = try wallet.getPassword()
//            let pk = try wallet.getPrivateKey(withPassword: password)
//            DispatchQueue.main.async { [unowned self] in
//                self.pk = pk
//            }
//        } catch {
//            alerts.showErrorAlert(for: self, error: error) {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//    }
//
//    func generateQRCode(from string: String) -> UIImage? {
//        var code: String
//        if let c = Web3.EIP67Code(address: string)?.toString() {
//            code = c
//        } else {
//            code = string
//        }
//        let data = code.data(using: String.Encoding.ascii)
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 3, y: 3)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//        return nil
//    }
//
//    func hideCopiedLabel(_ hidden: Bool = false) {
//        notificationLabel.alpha = hidden ? 0.0 : 1.0
//    }
//
//    @IBAction func copyButtonTapped(_ sender: UIButton) {
//        UIPasteboard.general.string = privateKeyLabel.text
//
//        DispatchQueue.main.async { [weak self] in
//            self?.hideCopiedLabel(true)
//            UIView.animate(withDuration: Constants.animationDuration,
//                           animations: {
//                            self?.hideCopiedLabel(false)
//            }, completion: { _ in
//                UIView.animate(withDuration: Constants.animationDuration, animations: {
//                    self?.hideCopiedLabel(true)
//                })
//            })
//        }
//    }
//
//}
