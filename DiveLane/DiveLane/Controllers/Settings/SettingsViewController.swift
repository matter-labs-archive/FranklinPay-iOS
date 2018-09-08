//
//  SettingsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    var settings = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSettings()
        
        self.title = "Settings"
        self.tabBarController?.tabBar.selectedItem?.title = nil
        
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        settingsTableView.tableFooterView = UIView()
        
        let nib = UINib.init(nibName: "SettingsCell", bundle: nil)
        self.settingsTableView.register(nib, forCellReuseIdentifier: "SettingsCell")
    }
    
    func getSettings() {
        settings["currentNetwork"] = (CurrentNetwork.currentNetwork ?? Networks.Mainnet)
        settings["currentWallet"] = KeysService().selectedWallet()?.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getSettings()
        self.settingsTableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsTableViewSections.main.rawValue:
            return 2
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case SettingsTableViewSections.main.rawValue:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SettingsTableViewSections.main.rawValue {
            return "Main settings"
        } else {
            return "..."
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SettingsTableViewSections.main.rawValue :
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            switch indexPath.row {
            case 0:
                cell.configure(param: "Network", value: settings["currentNetwork"] as Any)
            default:
                cell.configure(param: "Wallet", value: settings["currentWallet"] as Any)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySectionCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {return}
        let selectedCell = tableView.cellForRow(at: indexPathForSelectedRow) as? SettingsCell
        
        if selectedCell?.param.text == "Network" {
            let networksViewController = NetworksViewController()
            self.navigationController?.pushViewController(networksViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

