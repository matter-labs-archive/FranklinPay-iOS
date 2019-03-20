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
    
    // MARK: - Outlets

    @IBOutlet weak var settingsTableView: BasicTableView!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var slogan: UILabel!
    
    // MARK: - Internal lets
    
    internal var mainSettings: [SettingsModel] = []
    internal var walletsService = WalletsService()
    internal var settingsInteractor = SettingInteractor()
    internal let alerts = Alerts()
    internal let userKeys = UserDefaultKeys()
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
        setupNavigation()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
        setupVersion()
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
        prodName.text = Constants.prodName
        slogan.text = Constants.slogan
    }
    
    func setupVersion() {
        let dictionary = Bundle.main.infoDictionary!
        guard let vrsn = dictionary["CFBundleShortVersionString"] as? String else { return }
        guard let build = dictionary["CFBundleVersion"] as? String else { return }
        version.text = "Version \(vrsn) (\(build))"
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
    
    // MARK: - Table view setup and updates
    
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
