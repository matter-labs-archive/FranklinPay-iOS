//
//  ContactsVC+TableViewExtensions.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

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
        let contact = contactsList[indexPath.row]
        let alert = UIAlertController(title: contact.name, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [unowned self] (_) in
            let vc = SendMoneyController(token: Franklin(), address: contact.address)
            self.searchTextField.endEditing(true)
            self.modalViewAppeared()
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            vc.view.layer.speed = Constants.ModalView.animationSpeed
            self.tabBarController?.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [unowned self] (_) in
            let vc = AddContactController(contact: contact)
            self.searchTextField.endEditing(true)
            self.modalViewAppeared()
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            vc.view.layer.speed = Constants.ModalView.animationSpeed
            self.tabBarController?.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] (_) in
            DispatchQueue.main.async { [unowned self] in
                let searchString = self.searchTextField.text
                try? contact.deleteContact()
                self.searchContact(string: searchString ?? "")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
