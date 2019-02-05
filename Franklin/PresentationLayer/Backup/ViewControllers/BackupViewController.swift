//
//  BackupViewController.swift
//  Franklin
//
//  Created by Anton Grigorev on 01/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class BackupViewController: BasicViewController {

    enum BackupScreenStatus {
        case start
        case mnemonic
        case alert
    }
    
    var screenStatus: BackupScreenStatus = .start
    var mnemonicString: String = "" {
        didSet {
            mnemonic.text = mnemonicString
        }
    }
    
    let alerts = Alerts()
    
    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var mainInfo: UILabel!
    @IBOutlet weak var mnemonic: UILabel!
    @IBOutlet weak var alert: UILabel!
    
    @IBOutlet weak var mainButton: BasicWhiteButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mnemonic = CurrentWallet.currentWallet?.backup else {
            alerts.showErrorAlert(for: self, error: "Can't get mnemonic - reinstall app") {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        self.mnemonicString = mnemonic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStart(animated: false)
    }
    
    func showStart(animated: Bool) {
        self.screenStatus = .start
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.firstTitle.text = "Back up"
                self.firstTitle.textColor = Colors.mainBlue
                self.secondTitle.text = "your wallet"
                self.mainInfo.alpha = 1
                self.mnemonic.alpha = 0
                self.alert.alpha = 0
                
                self.mainButton.setTitle("BACK UP", for: .normal)
                self.mainButton.setImage(UIImage(named: "writing-tool"), for: .normal)
                self.mainButton.layer.borderColor = Colors.mainBlue.cgColor
                self.mainButton.changeColorOn(background: Colors.mainBlue, text: Colors.textWhite)
        }
    }
    
    func showMnemonic(animated: Bool) {
        self.screenStatus = .mnemonic
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.firstTitle.text = "Write down"
                self.firstTitle.textColor = Colors.mainBlue
                self.secondTitle.text = "recovery phrase"
                self.mainInfo.alpha = 0
                self.mnemonic.alpha = 1
                self.alert.alpha = 0
                
                self.mainButton.setTitle("DONE", for: .normal)
                self.mainButton.setImage(UIImage(named: "save-button"), for: .normal)
                self.mainButton.layer.borderColor = Colors.mainBlue.cgColor
                self.mainButton.changeColorOn(background: Colors.mainBlue, text: Colors.textWhite)
        }
    }
    
    func showAlert(animated: Bool) {
        self.screenStatus = .alert
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.firstTitle.text = "ATTENTION"
                self.firstTitle.textColor = Colors.orange
                self.secondTitle.text = ""
                self.mainInfo.alpha = 0
                self.mnemonic.alpha = 1
                self.alert.alpha = 1
                
                self.mainButton.setTitle("I AM SHURE", for: .normal)
                self.mainButton.setImage(UIImage(named: "save-button"), for: .normal)
                self.mainButton.layer.borderColor = Colors.orange.cgColor
                self.mainButton.changeColorOn(background: Colors.orange, text: Colors.textWhite)
        }
    }
    
    func finish() {
        do {
            let wallet = CurrentWallet.currentWallet!
            try wallet.performBackup()
            let selectedWallet = try WalletsService().getSelectedWallet()
            CurrentWallet.currentWallet = selectedWallet
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
        } catch let error {
            alerts.showErrorAlert(for: self, error: error) { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mainAction(_ sender: UIButton) {
        switch screenStatus {
        case .start:
            showMnemonic(animated: true)
        case .mnemonic:
            showAlert(animated: true)
        case .alert:
            finish()
        }
    }
    
}
