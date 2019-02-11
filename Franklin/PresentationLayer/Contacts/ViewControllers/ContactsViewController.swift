//
//  ContactsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import SideMenu

class ContactsViewController: BasicViewController, ModalViewDelegate {

    @IBOutlet weak var addContactButton: BasicBlueButton!
    @IBOutlet weak var searchTextField: BasicTextField!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var tableView: BasicTableView!
    @IBOutlet weak var emptyContactsView: UIView!
    
    var contactsList: [Contact] = []
    var filteredContactsList: [Contact] = []
    
    let userKeys = UserDefaultKeys()
    let contactsService = ContactsService()
    let alerts = Alerts()
    //let interactor = Interactor()
    
    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    private let reuseIdentifier = "ContactTableCell"
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let itemsPerRow: CGFloat = 3
    
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.background
        self.hideKeyboardWhenTappedAround()
        self.setupNavigation()
        self.setupTableView()
        self.setupSearch()
        self.additionalSetup()
        self.setupSideBar()
    }
    
    func setupMarker() {
        self.marker.isUserInteractionEnabled = false
        guard let wallet = CurrentWallet.currentWallet else {
            return
        }
        if userKeys.isBackupReady(for: wallet) {
            self.marker.alpha = 0
        } else {
            self.marker.alpha = 1
        }
    }
    
    func additionalSetup() {
        self.addContactButton.setTitle("Add contact", for: .normal)
        self.topViewForModalAnimation.blurView()
        self.topViewForModalAnimation.alpha = 0
        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        self.topViewForModalAnimation.isUserInteractionEnabled = false
        self.tabBarController?.view.addSubview(topViewForModalAnimation)
    }

    func setupNavigation() {
        self.navigationController?.navigationBar.isHidden = true
    }

    func setupTableView() {
        self.emptyContactsView.isUserInteractionEnabled = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        self.tableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: reuseIdentifier, bundle: nil)
        self.tableView.register(nibSearch, forCellReuseIdentifier: reuseIdentifier)
        self.contactsList.removeAll()
    }

    func setupSearch() {
        searchTextField.delegate = self
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupMarker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.setGestureForSidebar()
        self.getAllContacts()
    }
    
    func setupSideBar() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        //SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = 0.85 * UIScreen.main.bounds.width
        SideMenuManager.default.menuShadowOpacity = 0.5
        SideMenuManager.default.menuShadowColor = UIColor.black
        SideMenuManager.default.menuShadowRadius = 5
    }
    
    func modalViewBeenDismissed() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0
            })
        }
        getAllContacts()
    }
    
    func modalViewAppeared() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0.5
            })
        }
    }

    func getAllContacts() {
        do {
            let contacts = try contactsService.getAllContacts()
            updateContactsList(with: contacts)
        } catch {
            emptyContactsList()
            //updateContactsList(with: [])
        }
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    @IBAction func addContact(_ sender: Any) {
        self.searchTextField.endEditing(true)
        self.modalViewAppeared()
        let addContactController = AddContactController()
        addContactController.delegate = self
        addContactController.modalPresentationStyle = .overCurrentContext
        addContactController.view.layer.speed = Constants.ModalView.animationSpeed
        self.tabBarController?.present(addContactController, animated: true, completion: nil)
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
            self.emptyContactsList()
            return
        }
        self.updateContactsList(with: list)
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contactsList.isEmpty {
            return 0
        } else {
            return contactsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !contactsList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                                for: indexPath) as? ContactTableCell else {
                                                                    return UITableViewCell()
            }
            cell.configure(with: contactsList[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ContactsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string) as String
        if newText == "" {
            getAllContacts()
        } else {
            let contact = newText
            searchContact(string: contact)
        }
        return true
    }
}

//extension ContactsViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let width = UIScreen.main.bounds.width * Constants.CollectionView.widthCoeff - 15
//        
//        return CGSize(width: width, height: Constants.CollectionCell.height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
//}

extension ContactsViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewAppeared()
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewBeenDismissed()
    }
}
