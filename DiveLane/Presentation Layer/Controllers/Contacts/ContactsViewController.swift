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

        self.title = "Contacts"

        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        self.contactsTableView.tableFooterView = UIView()

        self.navigationItem.setRightBarButton(addContactBarItem(), animated: false)

        self.hideKeyboardWhenTappedAround()

        let nibSearch = UINib.init(nibName: "ContactCell", bundle: nil)
        self.contactsTableView.register(nibSearch, forCellReuseIdentifier: "ContactCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
        helpLabel.alpha = enabled ? 1 : 0
    }

    func emptyContactsList() {
        contactsList = []
        DispatchQueue.main.async { [weak self] in
            self?.contactsTableView.reloadData()
        }
    }

    func updateContactsList(with list: [ContactModel]) {
        contactsList = list
        DispatchQueue.main.async { [weak self] in
            self?.contactsTableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" {

            getAllContacts()
            makeHelpLabel(enabled: true)

        } else {

            let token = searchText
            makeHelpLabel(enabled: false)
            searchContact(string: token)

        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil && searchBar.text! != "" && (self.contactsList != nil) {
            //            let tokenToAdd = self.tokensList?.first
            //            chosenToken = tokenToAdd
            //            performSegue(withIdentifier: "addChosenToken", sender: self)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.contactsTableView.setContentOffset(.zero, animated: true)
        getAllContacts()
    }
}
