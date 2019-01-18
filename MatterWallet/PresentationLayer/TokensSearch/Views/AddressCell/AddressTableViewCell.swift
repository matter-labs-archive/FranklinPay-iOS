//
//  AddressTableViewCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var paste: UIButton!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        backView.backgroundColor = Colors.firstMain
        
        let height: CGFloat = 30
        let heightPasteContraint = NSLayoutConstraint(item: paste, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
        paste.addConstraint(heightPasteContraint)
        paste.layer.cornerRadius = height / 2
        paste.clipsToBounds = true
        let font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
        paste.backgroundColor = Colors.secondMain
        paste.titleLabel?.font = font
        paste.setTitleColor(Colors.firstMain, for: .normal)
        
        qr.setBackgroundImage(UIImage(named: "qr"), for: .normal)
        let heightQRContraint = NSLayoutConstraint(item: qr, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
        let qrWidth: CGFloat = 30
        let widthQRContraint = NSLayoutConstraint(item: qr, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: qrWidth)
        qr.addConstraints([heightQRContraint, widthQRContraint])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
