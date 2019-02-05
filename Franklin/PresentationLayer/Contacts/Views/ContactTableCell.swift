//
//  ContactCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class ContactTableCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.background
        self.topBackgroundView.backgroundColor = Colors.background
        //self.topBackgroundView.layer.cornerRadius = 10
        self.contactName.textColor = Colors.textDarkGray
        self.contactName.font = UIFont(name: Constants.TableContact.font, size: Constants.TableContact.maximumFontSize) ?? UIFont.systemFont(ofSize: Constants.TableContact.maximumFontSize)
        self.contactAddress.textColor = Colors.textLightGray
        
        self.contactAddress.font = UIFont(name: Constants.TableContact.font, size: Constants.TableContact.minimumFontSize) ?? UIFont.systemFont(ofSize: Constants.TableContact.minimumFontSize)
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
