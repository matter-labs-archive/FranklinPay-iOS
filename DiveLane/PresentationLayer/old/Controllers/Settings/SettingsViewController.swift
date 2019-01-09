//
//  SettingsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!

    var settings = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.tabBarController?.tabBar.selectedItem?.title = nil
        getSettings()
    }

    func getSettings() {
        do {
            self.settings["currentNetwork"] = (CurrentNetwork.currentNetwork )
            self.settings["currentWallet"] = try WalletsService().getSelectedWallet().name
        } catch let error {
            self.settings["currentWallet"] = error.localizedDescription
        }
        
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.settingsTableView.tableFooterView = UIView()
        
        let nib = UINib.init(nibName: "SettingsCell", bundle: nil)
        self.settingsTableView.register(nib, forCellReuseIdentifier: "SettingsCell")
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
            return settings.count
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
            return CGFloat(Constants.hightForRowInSettingsTableView)
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SettingsTableViewSections.main.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell",
                                                           for: indexPath) as? SettingsCell else {
                                                            return UITableViewCell()
            }
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

        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
            return
        }
        let selectedCell = tableView.cellForRow(at: indexPathForSelectedRow) as? SettingsCell

        if selectedCell?.param.text == "Network" {
            let networksViewController = NetworksViewController()
            self.navigationController?.pushViewController(networksViewController, animated: true)
        } else if selectedCell?.param.text == "Wallet" {
            let walletsViewController = WalletsViewController()
            self.navigationController?.pushViewController(walletsViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }

}
