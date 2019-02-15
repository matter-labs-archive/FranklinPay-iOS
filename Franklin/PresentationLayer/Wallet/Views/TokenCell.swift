//
//  TokenCell.swift
//  Franklin
//
//  Created by Anton on 12/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import Kingfisher

class TokenCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var middleBackgroundView: UIView!
    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var balance: UILabel!
    
    override func awakeFromNib() {
        self.balance.font = UIFont(name: Constants.TokenCell.Balance.font, size: Constants.TokenCell.Balance.size)
        self.balance.textColor = Constants.TokenCell.Balance.color
        self.title.font = UIFont(name: Constants.TokenCell.Title.font, size: Constants.TokenCell.Title.size)
        self.title.textColor = Constants.TokenCell.Title.color
        self.tokenImage.layer.cornerRadius = tokenImage.bounds.height/2
    }
    
    func configure(token: TableToken) {
        let balance = (token.token.balance ?? "-") + " \(token.token.symbol.uppercased())"
        let title = ("\(token.token.name)")
        
        self.balance.text = balance
        self.title.text = title
        self.tokenImage.layer.cornerRadius = self.tokenImage.bounds.height/2
        
        self.tokenImage.image = UIImage(named: "eth")
        if let url = URL(string: "https://trustwalletapp.com/images/tokens/\(token.token.address).png"), !token.token.isEther() {
            loadImage(url: url)
        }
    }
    
    func loadImage(url: URL?) {
        let processor = DownsamplingImageProcessor(size: self.tokenImage.bounds.size)
            >> RoundCornerImageProcessor(cornerRadius: self.tokenImage.bounds.height/2)
        self.tokenImage.kf.indicatorType = .activity
        self.tokenImage.kf.setImage(
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
        self.balance.text = "-"
        self.title.text = "-"
    }
}
