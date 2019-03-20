//
//  PublicKeyViewController.swift
//  Franklin
//
//  Created by Anton Grigorev on 24/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

class PublicKeyViewController: BasicViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var shareAddress: BasicBlueButton!
    @IBOutlet weak var copyAddress: BasicWhiteButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var publicKey: UILabel!
    
    // MARK: - Internal lets
    
    internal var wallet: Wallet
    internal let alerts = Alerts()
    
    internal var pk: String = "" {
        didSet {
            publicKey.text = pk
            qrCode.image = generateQRCode(from: pk)
        }
    }
    
    // MARK: - Weak vars
    
    weak var delegate: ModalViewDelegate?
    
    // MARK: - Inits
    
    init(for wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
        setup()
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
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
    
    func setup() {
        let pk = wallet.address
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
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: true)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func copyAction(_ sender: UIButton) {
        UIPasteboard.general.string = publicKey.text
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
}
