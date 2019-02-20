////
////  WalletsViewController.swift
////  DiveLane
////
////  Created by NewUser on 13/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class DepositsViewController: BasicViewController, ModalViewDelegate {
//    
//    @IBOutlet weak var tableView: BasicTableView!
//    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var backgroundView: UIView!
//    
//    let depositsCoordinator = DepositsCoordinator()
//    let alerts = Alerts()
//    
//    var deposits: [TableDeposit] = []
//    
//    var token: ERC20Token?
//    
//    weak var delegate: ModalViewDelegate?
//    
//    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
//    
//    convenience init(token: ERC20Token) {
//        self.init()
//        self.token = token
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.mainSetup()
//        self.setupNavigation()
//        self.setupTableView()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.additionalSetup()
//        self.updateTable()
//    }
//    
//    func mainSetup() {
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
//    }
//    
//    func additionalSetup() {
//        self.topViewForModalAnimation.blurView()
//        self.topViewForModalAnimation.alpha = 0
//        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
//        self.topViewForModalAnimation.isUserInteractionEnabled = false
//        self.view.addSubview(topViewForModalAnimation)
//    }
//    
//    func setupNavigation() {
//        navigationItem.title = "Deposits"
//        navigationController?.navigationBar.isHidden = false
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
//    }
//    
//    private func setupTableView() {
//        let nibToken = UINib.init(nibName: "DepositCell", bundle: nil)
//        tableView.delegate = self
//        tableView.dataSource = self
//        let footerView = UIView()
//        footerView.backgroundColor = Colors.background
//        tableView.tableFooterView = footerView
//        tableView.register(nibToken, forCellReuseIdentifier: "DepositCell")
//        deposits.removeAll()
//    }
//    
//    func updateTable() {
//        DispatchQueue.global().async { [unowned self] in
//            self.getdeposits()
//        }
//    }
//    
//    private func getdeposits() {
//        DispatchQueue.global().async {
//            let depositsArray = self.depositsCoordinator.getDeposits()
//            self.deposits = depositsArray
//            self.reloadDataInTable()
//        }
//    }
//    
//    func reloadDataInTable() {
//        DispatchQueue.main.async { [unowned self] in
//            self.tableView.reloadData()
//        }
//    }
//    
//    @IBAction func addDeposit(_ sender: BasicBlueButton) {
//        let vc = AddDepositViewController()
//        vc.delegate = self
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.view.layer.speed = Constants.ModalView.animationSpeed
//        self.present(vc, animated: true, completion: nil)
//    }
//    
//    @objc func addButtonTapped() {
//        //        let addWalletViewController = AddWalletViewController(isNavigationBarNeeded: true)
//        //        self.navigationController?.pushViewController(addWalletViewController, animated: true)
//    }
//    
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
//    
//    @IBAction func closeAction(_ sender: UIButton) {
//        self.dismissView()
//    }
//    
//    @objc func dismissView() {
//        self.dismiss(animated: true, completion: nil)
//        delegate?.modalViewBeenDismissed(updateNeeded: true)
//    }
//}
//
//extension DepositsViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return deposits.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DepositCell", for: indexPath) as? DepositCell else {
//            return UITableViewCell()
//        }
//        cell.configureCell(model: deposits[indexPath.row])
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(Constants.TableCells.Heights.deposits)
//    }
//    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//}
