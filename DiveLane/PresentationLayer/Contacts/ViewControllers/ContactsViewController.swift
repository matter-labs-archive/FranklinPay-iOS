//
//  ContactsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    @IBOutlet weak var contactsTableView: BasicTableView!
    @IBOutlet weak var helpLabel: UILabel!

    var contactsList: [Contact] = []

    var searchController: UISearchController!
    
    let contactsService = ContactsService()
    let alerts = Alerts()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.firstMain
        self.hideKeyboardWhenTappedAround()
        self.setupNavigation()
        self.setupTableView()
        self.setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.contactsTableView.reloadData()
        makeHelpLabel(enabled: false)
    }

    func setupNavigation() {
        self.title = "Contacts"
        self.navigationItem.setRightBarButton(addContactBarItem(), animated: false)
        self.navigationController?.navigationBar.isHidden = false
    }

    func setupTableView() {
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.firstMain
        self.contactsTableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: "ContactCell", bundle: nil)
        self.contactsTableView.register(nibSearch, forCellReuseIdentifier: "ContactCell")
        self.contactsList.removeAll()
    }

    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        contactsTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.white
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.searchController.hideKeyboardWhenTappedOutsideSearchBar(for: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllContacts()
    }

    func getAllContacts() {
        do {
            let contacts = try contactsService.getAllContacts()
            updateContactsList(with: contacts)
        } catch {
            updateContactsList(with: [])
        }
    }

    func addContactBarItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addContact))
        return addButton
    }

    @objc func addContact() {
        self.searchController.searchBar.endEditing(true)
        let addContactController = AddContactController()
        self.navigationController?.pushViewController(addContactController, animated: true)
    }

    func isContactsListEmpty() -> Bool {
        if contactsList.isEmpty {
            return true
        }
        return false
    }
    
    func makeHelpLabel(enabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.helpLabel.alpha = enabled ? 1 : 0
        }
    }
    
    func emptyContactsList() {
        contactsList = []
        DispatchQueue.main.async { [weak self] in
            self?.contactsTableView.reloadData()
        }
    }
    
    func updateContactsList(with list: [Contact]) {
        DispatchQueue.main.async { [weak self] in
            self?.contactsList = list
            if list.count == 0 && self?.searchController.searchBar.text == "" {
                self?.makeHelpLabel(enabled: true)
            }
            self?.contactsTableView.reloadData()
        }
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isContactsListEmpty() {
            return 0
        } else {
            return contactsList.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rows.heights.contacts
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isContactsListEmpty() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell",
                                                           for: indexPath) as? ContactCell else {
                                                            return UITableViewCell()
            }
            cell.configure(with: contactsList[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactsList[indexPath.row]
        let sendController = SendSettingsViewController(destinationAddress: contact.address)
        self.navigationController?.pushViewController(sendController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let contact = contactsList[indexPath.row]
                try contact.deleteContact()
                let searchText = self.searchController.searchBar.text ?? ""
                if searchText != "" {
                    self.searchContact(string: searchText)
                } else {
                    self.getAllContacts()
                }
            } catch let error {
                alerts.showErrorAlert(for: self, error: error, completion: nil)
            }
        }
    }
}

extension ContactsViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}

extension ContactsViewController: UISearchBarDelegate {

    func searchContact(string: String) {
        guard let list = try? ContactsService().getFullContactsList(for: string) else {
            self.emptyContactsList()
            return
        }
        self.updateContactsList(with: list)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            getAllContacts()
        } else {
            let contact = searchText
            searchContact(string: contact)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.contactsTableView.setContentOffset(.zero, animated: true)
        getAllContacts()
    }
}
