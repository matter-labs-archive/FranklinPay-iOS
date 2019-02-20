//
//  NetworksViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

class NetworksViewController: BasicViewController {

    @IBOutlet weak var networksTableView: BasicTableView!

    var networks: [Web3Network] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setupTableView()
    }
    
    func setupNavigation() {
        navigationItem.title = "Networks"
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupTableView() {
        let nibToken = UINib.init(nibName: "NetworksCell", bundle: nil)
        networksTableView.delegate = self
        networksTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        networksTableView.tableFooterView = footerView
        networksTableView.register(nibToken, forCellReuseIdentifier: "NetworksCell")
        networks.removeAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNetworks()
    }

    func getNetworks() {
        DispatchQueue.global().async {
            let basicNetworks: [Networks] = [.Mainnet,
                                             .Rinkeby,
                                             .Ropsten,
                                             .Kovan]
            var web3networks: [Web3Network]
            let basicWeb3Nets = basicNetworks.map({
                Web3Network(network: $0)
            })
            web3networks = basicWeb3Nets
            let xdai = Web3Network(id: 100, name: "xDai")
            web3networks.append(xdai)
            self.networks = web3networks
            self.reloadDataInTable()
        }
    }
    
    func reloadDataInTable() {
        DispatchQueue.main.async { [weak self] in
            self?.networksTableView.reloadData()
        }
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
        return CGFloat(Constants.TableCells.Heights.networks)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentNetwork = CurrentNetwork.currentNetwork
        let networkInCell = networks[indexPath.row]
        var isChosen = false
        if currentNetwork == networkInCell {
            isChosen = true
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NetworksCell",
                                                       for: indexPath) as? NetworksCell else {
                                                        return UITableViewCell()
        }
        cell.configure(network: networkInCell, isChosen: isChosen)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CurrentNetwork.currentNetwork = networks[indexPath.row]
        self.networksTableView.deselectRow(at: indexPath, animated: true)
        self.reloadDataInTable()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
