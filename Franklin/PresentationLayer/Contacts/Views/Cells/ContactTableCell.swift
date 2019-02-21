//
//  ContactTableCell.swift
//  Franklin
//
//  Created by Anton Grigorev on 06/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import BlockiesSwift

class ContactTableCell: UITableViewCell {
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with contact: Contact) {
        contactName.text = contact.name
        contactAddress.text = contact.address
        let blockies = Blockies(seed: contact.address,
                                size: 10,
                                scale: 100)
        let img = blockies.createImage()
        contactImage.image = img
        contactImage.layer.cornerRadius = Constants.CollectionCell.Image.cornerRadius
        contactImage.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contactName.text = ""
        contactAddress.text = ""
    }
    
}
