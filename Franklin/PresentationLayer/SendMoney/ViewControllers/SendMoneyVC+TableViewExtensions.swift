//
//  SendMoneyVC+TableViewExtensions.swift
//  Franklin
//
//  Created by Anton on 21/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension SendMoneyController {
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
            emptyContactsList()
            return
        }
        updateContactsList(with: list)
    }
    
    func emptyAttention(enabled: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.emptyContactsView.alpha = enabled ? 1 : 0
        }
    }
}

extension SendMoneyController: UITableViewDelegate, UITableViewDataSource {
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
        let contact = contactsList[indexPath.row]
        showConfirmScreen(animated: true, for: contact)
    }
}
