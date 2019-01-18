//
//  ContactCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.firstMain
        self.topBackgroundView.backgroundColor = Colors.secondMain
        self.topBackgroundView.layer.cornerRadius = 10
        self.contactName.textColor = Colors.textFirst
        self.contactName.font = UIFont(name: Constants.font, size: Constants.basicFontSize) ?? UIFont.systemFont(ofSize: Constants.basicFontSize)
        self.contactAddress.textColor = Colors.textSecond
        
        self.contactAddress.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
    }
    
    func configure(with contact: Contact) {
        self.contactName.text = contact.name
        self.contactAddress.text = contact.address
        self.contactImage.image = UIImage(named: "contacts_gray")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contactName.text = ""
        self.contactAddress.text = ""
    }

}
