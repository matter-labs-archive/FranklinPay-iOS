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
    
    @IBOutlet weak var shareAddress: BasicBlueButton!
    @IBOutlet weak var copyAddress: BasicWhiteButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var publicKey: UILabel!
    
    var wallet: Wallet
    
    let alerts = Alerts()
    
    weak var delegate: ModalViewDelegate?
    
    var pk: String = "" {
        didSet {
            self.publicKey.text = pk
            self.qrCode.image = self.generateQRCode(from: pk)
        }
    }
    
    init(for wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainSetup()
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = true
        
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
    
    func setup() {
        let pk = wallet.address
        DispatchQueue.main.async { [unowned self] in
            self.pk = pk
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        var code: String
        if let c = Web3.EIP67Code(address: string)?.toString() {
            code = c
        } else {
            code = string
        }
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
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
    }
    
    @IBAction func copyAction(_ sender: UIButton) {
        UIPasteboard.general.string = publicKey.text
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        let addressToShare: String = pk
        
        let itemsToShare = [ addressToShare ]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.markupAsPDF ]
        self.present(activityViewController, animated: true, completion: nil)
    }
}
