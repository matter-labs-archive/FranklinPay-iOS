//
//  ContactCell.swift
//  Franklin
//
//  Created by Anton Grigorev on 23/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import BlockiesSwift

class ContactCell: UICollectionViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with contact: Contact) {
        self.name.text = contact.name
        let blockies = Blockies(seed: contact.address,
                                size: 5,
                                scale: 4,
                                color: Colors.mainGreen,
                                bgColor: Colors.mostLightGray, spotColor: Colors.mainBlue)
        let img = blockies.createImage()
        self.photo.image = img
        photo.layer.cornerRadius = Constants.CollectionCell.Image.cornerRadius
        photo.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.name.text = ""
    }

}
