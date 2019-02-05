//
//  SettingsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import SideMenu

class SettingsViewController: BasicViewController, ModalViewDelegate {

    @IBOutlet weak var settingsTableView: BasicTableView!

    var mainSettings: [MainSetting] = []
    var walletsService = WalletsService()
    var settingsInteractor = SettingInteractor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTable()
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupTableView() {
        let nibToken = UINib.init(nibName: "SettingsCell", bundle: nil)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        settingsTableView.tableFooterView = footerView
        settingsTableView.register(nibToken, forCellReuseIdentifier: "SettingsCell")
        mainSettings.removeAll()
    }
    
    func updateTable() {
        DispatchQueue.global().async { [weak self] in
            self?.getSettings()
        }
    }
    
    func reloadDataInTable() {
        DispatchQueue.main.async { [weak self] in
            self?.settingsTableView.reloadData()
        }
    }
    
    private func getSettings() {
        let settings = self.settingsInteractor.getMainSettings()
        self.mainSettings = settings
        self.reloadDataInTable()
    }
    
    func modalViewBeenDismissed() {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = 0
//            })
//        }
    }
    
    func modalViewAppeared() {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
//            })
//        }
    }
}

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
        return Constants.TableCells.Heights.settings
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
        if setting == MainSetting(.backup) {
            let backupVC = BackupViewController()
            self.navigationController?.pushViewController(backupVC, animated: true)
        } else if setting == MainSetting(.pincode) {
            let pincodeVC = CreatePincodeViewController()
            self.navigationController?.pushViewController(pincodeVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
