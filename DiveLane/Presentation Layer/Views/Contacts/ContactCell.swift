//
//  ContactCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!

    func configure(with contact: ContactModel) {
        contactAddress.text = contact.address
        contactName.text = contact.name
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.contactName.text = ""
        self.contactAddress.text = ""
        self.contactImage.image = UIImage(named: "contacts_gray")
    }

}
