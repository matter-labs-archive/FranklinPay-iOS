//
//  SettingsVC+ TableViewExtensions.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsTableViewSections.main.rawValue:
            return mainSettings.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * Constants.SettingCell.heightCoef
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
            let setting = mainSettings[indexPath.row]
            cell.configure(setting: setting)
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
        let setting = mainSettings[indexPathForSelectedRow.row]
        switch setting {
        case SettingsModel(.backup):
            presentVC(BackupViewController())
        case SettingsModel(.pincode):
            presentVC(CreatePincodeViewController())
        case SettingsModel(.wallet):
            presentVC(WalletsViewController())
        case SettingsModel(.network):
            presentVC(NetworksViewController())
        case SettingsModel(.changePincode):
            presentVC(EnterPincodeViewController(for: .changePincode, data: Data()))
        default:
            alerts.showErrorAlert(for: self, error: "Coming soon", completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func presentVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
