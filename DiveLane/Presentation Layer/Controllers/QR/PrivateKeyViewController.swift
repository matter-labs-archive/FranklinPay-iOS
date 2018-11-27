//
//  PrivateKeyViewController.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

class PrivateKeyViewController: UIViewController {
    @IBOutlet weak var privateQRimageView: UIImageView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!

    var pk: String

    init(pk: String) {
        self.pk = pk
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideCopiedLabel(true)
        privateQRimageView.image = generateQRCode(from: pk)
        privateKeyLabel.text = pk
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

    func hideCopiedLabel(_ hidden: Bool = false) {
        notificationLabel.alpha = hidden ? 0.0 : 1.0
    }

    @IBAction func copyButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = privateKeyLabel.text

        DispatchQueue.main.async { [weak self] in
            self?.hideCopiedLabel(true)
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self?.hideCopiedLabel(false)
            }, completion: { _ in
                UIView.animate(withDuration: 2.0, animations: {
                    self?.hideCopiedLabel(true)
                })
            })
        }
    }

}
