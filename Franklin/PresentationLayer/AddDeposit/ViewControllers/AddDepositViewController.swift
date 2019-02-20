////
////  PublicKeyViewController.swift
////  Franklin
////
////  Created by Anton Grigorev on 24/01/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import UIKit
//import Web3swift
//
//class AddDepositViewController: BasicViewController {
//    
//    @IBOutlet weak var saveBtn: BasicBlueButton!
//    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var amountField: BasicTextField!
//    @IBOutlet weak var dateField: BasicTextField!
//    @IBOutlet var textFields: [BasicTextField]!
//    @IBOutlet weak var resultLabel: UILabel!
//    
//    let alerts = Alerts()
//    
//    weak var delegate: ModalViewDelegate?
//    
//    enum TextFieldsTags: Int {
//        case amount = 0
//        case date = 1
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setDate()
//    }
//    
//    func setDate() {
//        let date = Date().addingTimeInterval(31536000)
//        let calendar = Calendar.current
//        
//        let year = calendar.component(.year, from: date)
//        let month = calendar.component(.month, from: date)
//        let day = calendar.component(.day, from: date)
//        
//        self.dateField.text = "\(month)/\(day)/\(year)"
//    }
//    
//    func setAttention(_ amount: String) {
//        guard let double = Double(amount) else {
//            self.resultLabel.text = "Enter amount"
//            return
//        }
//        let newAmount = Double(round(1000*double*1.1)/1000) 
//        self.resultLabel.text = "You will get \(newAmount) at \(self.dateField.text ?? "0\0\0")"
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.mainSetup()
//        self.setupTextField()
//    }
//    
//    func setupTextField() {
//        self.amountField.delegate = self
//        self.dateField.delegate = self
//        self.amountField.tag = TextFieldsTags.amount.rawValue
//        self.dateField.tag = TextFieldsTags.date.rawValue
//        self.dateField.isUserInteractionEnabled = false
//        amountField.returnKeyType = .next
//        dateField.returnKeyType = .next
//    }
//    
//    func mainSetup() {
//        self.resultLabel.text = "Enter amount"
//        
//        self.hideKeyboardWhenTappedAround()
//        
//        self.navigationController?.navigationBar.isHidden = true
//        saveBtn.isEnabled = false
//        updateSaveButtonAlpha()
//        
//        view.backgroundColor = UIColor.clear
//        view.isOpaque = false
//        self.contentView.backgroundColor = Colors.background
//        self.contentView.alpha = 1
//        self.contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
//        self.contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
//        self.contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
//        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
//                                                                 action: #selector(self.dismissView))
//        tap.cancelsTouchesInView = false
//        backgroundView.addGestureRecognizer(tap)
//        
//        //        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
//        //                                                                 action: #selector(self.dismissKeyboard))
//        //        dismissKeyboard.cancelsTouchesInView = false
//        //        self.contentView.addGestureRecognizer(dismissKeyboard)
//    }
//    
//    @objc func dismissView() {
//        self.dismiss(animated: true, completion: nil)
//        delegate?.modalViewBeenDismissed(updateNeeded: true)
//    }
//    
//    @IBAction func closeAction(_ sender: UIButton) {
//        self.dismissView()
//    }
//    
//    @IBAction func addDepositButtonTapped(_ sender: Any) {
//        
//        guard let amount = amountField.text else {
//            return
//        }
//        
//        guard let date = dateField.text else {
//            return
//        }
//        
//        self.addDeposit(amount: amount, date: date)
//        
//    }
//    
//    private func addDeposit(amount: String, date: String) {
//        guard let wallet = CurrentWallet.currentWallet else {
//            return
//        }
//        do {
////            let password = try wallet.getPassword()
////            let tx = try wallet.prepareWriteContractTx(web3instance: nil, contractABI: CreditAbi, contractAddress: CreditAddress, contractMethod: "createDeposit", value: "0.0", gasLimit: .automatic, gasPrice: .automatic, parameters: [date, amount] as [AnyObject], extraData: Data())
////            let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//            self.dismissView()
//        } catch let error {
//            return
//        }
//    }
//    
//    private func updateSaveButtonAlpha() {
//        saveBtn.alpha = saveBtn.isEnabled ? 1.0 : 0.5
//    }
//    
//    private func isSaveButtonEnabled(afterChanging textField: UITextField, with string: String) {
//        saveBtn.isEnabled = false
//        let everyFieldIsOK: Bool
//        switch textField {
//        case amountField:
//            everyFieldIsOK = !(dateField.text?.isEmpty ?? true) && !string.isEmpty
//        default:
//            everyFieldIsOK = !(amountField.text?.isEmpty ?? true) && !string.isEmpty
//        }
//        saveBtn.isEnabled = everyFieldIsOK
//    }
//}
//extension AddDepositViewController: UITextFieldDelegate {
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentText = (textField.text ?? "") as NSString
//        let futureString = currentText.replacingCharacters(in: range, with: string) as String
//        
//        isSaveButtonEnabled(afterChanging: textField, with: futureString)
//        
//        updateSaveButtonAlpha()
//        
//        textField.returnKeyType = saveBtn.isEnabled ? UIReturnKeyType.done : .next
//        
//        setAttention(futureString)
//        
//        return true
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.tag == TextFieldsTags.amount.rawValue && !saveBtn.isEnabled {
//            dateField.becomeFirstResponder()
//            return false
//        } else if textField.tag == TextFieldsTags.date.rawValue && !saveBtn.isEnabled {
//            amountField.becomeFirstResponder()
//            return false
//        } else if saveBtn.isEnabled {
//            textField.resignFirstResponder()
//            return true
//        }
//        return false
//    }
//    
//}
