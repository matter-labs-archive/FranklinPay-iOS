//
//  NetworksVC+TableViewDelegates.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension NetworksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * Constants.NetworkCell.heightCoef
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
        let network = networks[indexPath.row].network
        selectNetwork(network)
        networksTableView.deselectRow(at: indexPath, animated: true)
        reloadDataInTable()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let network = networks[indexPath.row].network
        if network.isMainnet()
            || network.isRinkebi()
            || network.isRopsten()
            || network.isXDai() {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let network = networks[indexPath.row].network
            do {
                try network.delete()
            } catch let error {
                alerts.showErrorAlert(for: self, error: "Can't delete network: \(error)", completion: nil)
            }
            networks.remove(at: indexPath.row)
            let currentNetwork = networks[0].network
            selectNetwork(currentNetwork)
            reloadDataInTable()
        }
    }
}
