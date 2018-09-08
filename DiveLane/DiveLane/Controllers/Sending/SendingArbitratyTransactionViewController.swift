//
//  SendingArbitratyTransactionViewController.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class SendArbitraryTransactionViewController: UIViewController {
    
    @IBOutlet weak var balanceOnWalletTextField: UILabel!
    @IBOutlet weak var fromTextField: UILabel!
    @IBOutlet weak var contractAddressTextField: UITextField!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var methodNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var params: [Parameter]
    var transactionInfo: TransactionInfo
    
    init(params: [Parameter], transactionInfo: TransactionInfo) {
        self.params = params
        self.transactionInfo = transactionInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib.init(nibName: "ParameterCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ParameterCell")
        
        self.title = "Transaction"
        //TODO: - Setup outlets
    }
    
    
    @IBAction func sendButtonWasTapped(_ sender: Any) {
        //TODO: - Password
        TransactionsService().sendToContract(transaction: transactionInfo.transactionIntermediate, with: "") { (result) in
            switch result {
            case .Error(let error):
                print(error)
            case .Success(let success):
                print(success)
                //TODO: - Something
            }
        }
    }
    
}

extension SendArbitraryTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return params.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell", for: indexPath) as? ParameterCell else { return UITableViewCell() }
        cell.configure(params[indexPath.row])
        return cell
    }
    
}
