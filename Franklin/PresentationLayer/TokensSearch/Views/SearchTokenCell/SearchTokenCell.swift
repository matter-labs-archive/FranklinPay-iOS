//
//  SearchTokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 17/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

import Web3swift
import EthereumAddress
import Kingfisher

class SearchTokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addedIcon: UIImageView!
    @IBOutlet weak var tokenIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addedIcon.image = UIImage(named: "added")
        self.selectionStyle = .none
    }

    func configure(with token: ERC20Token, isAdded: Bool = false) {
        let title = "\(token.name) (\(token.symbol.uppercased()))"
        self.title.text = title
        addressLabel.text = token.address.hideExtraSymbolsInAddress()
        addedIcon.alpha = isAdded ? 1.0 : 0.0
        
        self.tokenIcon.layer.cornerRadius = self.tokenIcon.bounds.height/2
        
        self.tokenIcon.image = UIImage(named: token.address.lowercased()) ?? UIImage(named: "eth")
        if let url = URL(string: "https://trustwalletapp.com/images/tokens/\(token.address).png") {
            loadImage(url: url)
        }
    }
    
    func loadImage(url: URL?) {
        let processor = DownsamplingImageProcessor(size: self.tokenIcon.bounds.size)
            >> RoundCornerImageProcessor(cornerRadius: self.tokenIcon.bounds.height/2)
        self.tokenIcon.kf.indicatorType = .activity
        self.tokenIcon.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ]) {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.title.text = ""
        self.addressLabel.text = ""
        self.addedIcon.image = UIImage(named: "added")
        self.addedIcon.alpha = 0.0
    }
}
