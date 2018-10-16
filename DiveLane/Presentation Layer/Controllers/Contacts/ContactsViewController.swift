//
//  ContactsViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var helpLabel: UILabel!

    var contactsList: [ContactModel]?

    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setTableView()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setSearchController()
        self.searchController.hideKeyboardWhenTappedOutsideSearchBar(for: self)
        makeHelpLabel(enabled: false)
    }

    func setNavigation() {
        self.title = "Contacts"
        self.navigationItem.setRightBarButton(addContactBarItem(), animated: false)
    }

    func setTableView() {
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.contactsTableView.tableFooterView = UIView()
        let nibSearch = UINib.init(nibName: "ContactCell", bundle: nil)
        self.contactsTableView.register(nibSearch, forCellReuseIdentifier: "ContactCell")
    }

    func setSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        contactsTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.white
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllContacts()
    }

    func getAllContacts() {
        let contacts = ContactsDatabase().getAllContacts()
        updateContactsList(with: contacts)
    }

    func addContactBarItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addContact))
        return addButton
    }

    @objc func addContact() {
        let addContactController = AddContactController()
        self.navigationController?.pushViewController(addContactController, animated: true)
    }

    func isContactsListEmpty() -> Bool {
        if contactsList == nil || contactsList == [] {
            return true
        }
        return false
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isContactsListEmpty() {
            return 0
        } else {
            return (contactsList?.count)!
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isContactsListEmpty() {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell",
                                                           for: indexPath) as? ContactCell else {
                                                            return UITableViewCell()
            }
            cell.configure(with: contactsList?[indexPath.row] ?? ContactModel(address: "Unknown", name: "Unknown"))
            return cell

        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        guard let token = self.tokensList?[indexPath.row] else {
//            return
//        }
//
//        //        change(token: token, fromCurrentStatus: tokensIsAdded?[indexPath.row] ?? true)
//
//        let tokenInfoViewController = TokenInfoViewController(token: token,
//                                                              isAdded: tokensIsAdded?[indexPath.row] ?? true,
//                                                              interactor: interactor)
//
//        tokenInfoViewController.transitioningDelegate = self
//
//        self.present(tokenInfoViewController, animated: true, completion: nil)
//
        tableView.deselectRow(at: indexPath, animated: true)

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let contact = contactsList?[indexPath.row] else {return}
        if editingStyle == .delete {
            ContactsDatabase().deleteContact(contact: contact) { [weak self] (_) in
                let searchText = self?.searchController.searchBar.text ?? ""
                if searchText != "" {
                    self?.searchContact(string: searchText)
                } else {
                    self?.getAllContacts()
                }
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

        ContactsService().getFullContactsList(for: string, completion: { [weak self] (result) in
            if let list = result {
                self?.updateContactsList(with: list)
            } else {
                self?.getAllContacts()
            }
        })
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

    func updateContactsList(with list: [ContactModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.contactsList = list
            if list.count == 0 && self?.searchController.searchBar.text == "" {
                self?.makeHelpLabel(enabled: true)
            }
            self?.contactsTableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            getAllContacts()
        } else {
            let token = searchText
            searchContact(string: token)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.contactsTableView.setContentOffset(.zero, animated: true)
        getAllContacts()
    }
}
