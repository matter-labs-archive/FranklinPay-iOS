////
////  TokenInfoViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 02.10.2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class TokenInfoViewController: UIViewController {
//
//    @IBOutlet weak var tokenInfoTableView: UITableView!
//
//    @IBOutlet weak var addingButton: UIButton!
//
//    var wallet: WalletModel?
//
//    var interactor: Interactor?
//
//    let conversionService = RatesService.service
//
//    var token: ERC20TokenModel?
//    var isAdded: Bool = false
//    var rate: Double?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if wallet == nil {
//            do {
//                wallet = try WalletsService().getSelectedWallet()
//            } catch {
//                return
//            }
//        }
//
//        addingButton.setTitle(isAdded ? "DELETE" : "ADD", for: .normal)
//
//        let nib = UINib.init(nibName: "TokenInfoCell", bundle: nil)
//        self.tokenInfoTableView.delegate = self
//        self.tokenInfoTableView.dataSource = self
//        self.tokenInfoTableView.tableFooterView = UIView()
//        self.tokenInfoTableView.register(nib, forCellReuseIdentifier: "TokenInfoCell")
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        do {
//            let rate = try conversionService.updateConversionRate(for: token?.symbol.uppercased() ?? "ETH")
//            self.rate = rate
//            DispatchQueue.main.async { [weak self] in
//                self?.tokenInfoTableView.reloadData()
//            }
//        } catch {
//            return
//        }
//    }
//
//    @IBAction func close(sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
//        let percentThreshold: CGFloat = 0.3
//
//        let translation = sender.translation(in: view)
//        let verticalMovement = translation.y / view.bounds.height
//        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
//        let downwardMovementPercent = fminf(downwardMovement, 1.0)
//        let progress = CGFloat(downwardMovementPercent)
//
//        guard let interactor = interactor else { return }
//
//        switch sender.state {
//        case .began:
//            interactor.hasStarted = true
//            dismiss(animated: true, completion: nil)
//        case .changed:
//            interactor.shouldFinish = progress > percentThreshold
//            interactor.update(progress)
//        case .cancelled:
//            interactor.hasStarted = false
//            interactor.cancel()
//        case .ended:
//            interactor.hasStarted = false
//            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
//        default:
//            break
//        }
//    }
//
//    convenience init(token: ERC20TokenModel, isAdded: Bool, interactor: Interactor) {
//        self.init()
//        self.token = token
//        self.isAdded = isAdded
//        self.interactor = interactor
//    }
//
//    @IBAction func addTokenAction(_ sender: UIButton) {
//
//        guard let currentWallet = wallet else {
//            return
//        }
//
//        guard let token = token else {
//            return
//        }
//
//        let networkID = CurrentNetwork().getNetworkID()
//
//        if isAdded {
//            do {
//                try TokensService().deleteToken(token: token, wallet: currentWallet, networkId: networkID)
//                DispatchQueue.main.async { [weak self] in
//                    self?.dismiss(animated: true, completion: nil)
//                }
//            } catch {
//                DispatchQueue.main.async { [weak self] in
//                    self?.dismiss(animated: true, completion: nil)
//                }
//            }
//        } else {
//            do {
//                try TokensService().saveCustomToken(token: token, wallet: currentWallet, networkId: networkID)
//                DispatchQueue.main.async { [weak self] in
//                    self?.dismiss(animated: true, completion: nil)
//                }
//            } catch {
//                DispatchQueue.main.async { [weak self] in
//                    self?.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
//    }
//}
//
//extension TokenInfoViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 4
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenInfoCell",
//                                                       for: indexPath) as? TokenInfoCell else {
//                                                        return UITableViewCell()
//        }
//        guard token != nil else {return cell}
//        switch indexPath.row {
//        case TokenInfoRaws.name.rawValue :
//            cell.configure(with: "Token", value: token?.name, measurment: nil)
//        case TokenInfoRaws.address.rawValue :
//            cell.configure(with: "Address", value: token?.address, measurment: nil)
//        case TokenInfoRaws.currency.rawValue :
//            if token != nil {
//                let rate = "\(conversionService.currentConversionRate(for: (self.token?.symbol.uppercased())!))$"
//                cell.configure(with: "Currency", value: rate, measurment: (token?.name ?? ""))
//            } else {
//                cell.configure(with: "Currency", value: "Error in token", measurment: (token?.name ?? ""))
//            }
//        case TokenInfoRaws.decimals.rawValue :
//            cell.configure(with: "Decimals", value: token?.decimals, measurment: nil)
//        default:
//            break
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true)
//
//    }
//
//}
