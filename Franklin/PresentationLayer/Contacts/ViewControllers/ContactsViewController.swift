//
//  ContactsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import SideMenu

class ContactsViewController: BasicViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var addContactButton: BasicBlueButton!
    @IBOutlet weak var searchTextField: BasicTextField!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var tableView: BasicTableView!
    @IBOutlet weak var emptyContactsView: UIView!
    
    // MARK: - Internal lets
    
    internal let reuseIdentifier = "ContactTableCell"
    
    internal var contactsList: [Contact] = []
    internal var filteredContactsList: [Contact] = []
    
    internal let userKeys = UserDefaultKeys()
    internal let contactsService = ContactsService()
    internal let alerts = Alerts()
    
    internal let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    internal var searchActive : Bool = false
    
    // MARK: - Lifesycle

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        hideKeyboardWhenTappedAround()
        setupNavigation()
        setupTableView()
        setupSearch()
        additionalSetup()
        setupSideBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setGestureForSidebar()
        getAllContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMarker()
    }
    
    // MARK: - Main setup
    
    func createView() {
        view.backgroundColor = Colors.background
        tabBarController?.view.addSubview(topViewForModalAnimation)
        addContactButton.setTitle("Add contact", for: .normal)
    }
    
    func setupMarker() {
        marker.isUserInteractionEnabled = false
        guard let wallet = CurrentWallet.currentWallet else {
            return
        }
        if userKeys.isBackupReady(for: wallet) {
            marker.alpha = 0
        } else {
            marker.alpha = 1
        }
    }
    
    func additionalSetup() {
        topViewForModalAnimation.blurView()
        topViewForModalAnimation.alpha = 0
        topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        topViewForModalAnimation.isUserInteractionEnabled = false
    }

    func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupSideBar() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        //SideMenuManager.default.menuAddPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = 0.85 * UIScreen.main.bounds.width
        SideMenuManager.default.menuShadowOpacity = 0.5
        SideMenuManager.default.menuShadowColor = UIColor.black
        SideMenuManager.default.menuShadowRadius = 5
    }
    
    // MARK: - Table view setup and updates

    func setupTableView() {
        emptyContactsView.isUserInteractionEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        tableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: reuseIdentifier, bundle: nil)
        tableView.register(nibSearch, forCellReuseIdentifier: reuseIdentifier)
        contactsList.removeAll()
    }

    func setupSearch() {
        searchTextField.delegate = self
        definesPresentationContext = true
    }
    
    // MARK: - Table view setup and updates

    func getAllContacts() {
        do {
            let contacts = try contactsService.getAllContacts()
            updateContactsList(with: contacts)
        } catch {
            emptyContactsList()
            //updateContactsList(with: [])
        }
    }
    
    func emptyAttention(enabled: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.emptyContactsView.alpha = enabled ? 1 : 0
        }
    }
    
    func emptyContactsList() {
        contactsList = []
        emptyAttention(enabled: true)
        DispatchQueue.main.async { [unowned self] in
            self.tableView?.reloadData()
        }
    }
    
    func updateContactsList(with list: [Contact]) {
        DispatchQueue.main.async { [unowned self] in
            self.contactsList = list
            self.emptyAttention(enabled: list.isEmpty)
            self.tableView?.reloadData()
        }
    }
    
    func searchContact(string: String) {
        guard let list = try? ContactsService().getFullContactsList(for: string) else {
            getAllContacts()
            return
        }
        updateContactsList(with: list)
    }
    
    // MARK: - Buttons actions
    
    @IBAction func showMenu(_ sender: UIButton) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    @IBAction func addContact(_ sender: Any) {
        searchTextField.endEditing(true)
        modalViewAppeared()
        let addContactController = AddContactController()
        addContactController.delegate = self
        addContactController.modalPresentationStyle = .overCurrentContext
        addContactController.view.layer.speed = Constants.ModalView.animationSpeed
        tabBarController?.present(addContactController, animated: true, completion: nil)
    }
}
