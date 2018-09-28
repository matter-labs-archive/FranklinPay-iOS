//
//  NetworksViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class NetworksViewController: UIViewController {

    @IBOutlet weak var networksTableView: UITableView!

    var networks = [Networks]()
    var webs = [web3]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getNetworks()

        self.networksTableView.delegate = self
        self.networksTableView.dataSource = self
        networksTableView.tableFooterView = UIView()

        let nib = UINib.init(nibName: "NetworksCell", bundle: nil)
        self.networksTableView.register(nib, forCellReuseIdentifier: "NetworksCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Networks"
    }

    func getNetworks() {
        self.networks = [.Mainnet,
                         .Rinkeby,
                         .Ropsten]
        self.webs = [Web3.InfuraMainnetWeb3(),
                     Web3.InfuraRinkebyWeb3(),
                     Web3.InfuraRopstenWeb3()]
    }

}

extension NetworksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.heightForRowInNetworksTableView)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NetworksCell",
                                                       for: indexPath) as? NetworksCell else {
                                                        return UITableViewCell()
        }
        cell.configure(network: networks[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        CurrentNetwork.currentNetwork = networks[indexPath.row]
        CurrentWeb.currentWeb = webs[indexPath.row]
        DispatchQueue.global().async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
//            if !UserDefaultKeys().isEtherAdded {
//                guard let wallet = KeysService().selectedWallet() else {return}
//                AppController().addFirstToken(for: wallet, completion: { (error) in
//                    if error == nil {
//                        UserDefaultKeys().setEtherAdded()
//                        UserDefaults.standard.synchronize()
//
//                        self.navigationController?.popViewController(animated: true)
//                    } else {
//                        fatalError("Can't add ether - \(String(describing: error))")
//                    }
//                })
//            }
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }

}
