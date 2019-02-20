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

class SettingsViewController: BasicViewController {

    @IBOutlet weak var settingsTableView: BasicTableView!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var slogan: UILabel!
    
    var mainSettings: [SettingsModel] = []
    var walletsService = WalletsService()
    var settingsInteractor = SettingInteractor()
    let alerts = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
        setupVersion()
        prodName.text = Constants.prodName
        slogan.text = Constants.slogan
    }
    
    func setupVersion() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        version.text = "Version \(version) (\(build))"
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
        let settings = settingsInteractor.getMainSettings()
        mainSettings = settings
        reloadDataInTable()
    }
    
    
}

