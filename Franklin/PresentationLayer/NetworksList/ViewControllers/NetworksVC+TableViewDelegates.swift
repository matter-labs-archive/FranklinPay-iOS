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
        networksTableView.deselectRow(at: indexPath, animated: true)
        reloadDataInTable()
    }
}
