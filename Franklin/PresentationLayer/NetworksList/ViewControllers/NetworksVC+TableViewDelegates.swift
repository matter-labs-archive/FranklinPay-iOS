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
        CurrentNetwork.currentNetwork = networks[indexPath.row].network
        var networksArray = [TableNetwork]()
        for network in networks {
            var n = network
            n.isSelected = network.network == networks[indexPath.row].network ? true : false
            networksArray.append(n)
        }
        networks = networksArray
        reloadDataInTable()
        networksTableView.deselectRow(at: indexPath, animated: true)
    }
}
