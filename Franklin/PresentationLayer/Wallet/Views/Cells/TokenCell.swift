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
        balance.font = UIFont(name: Constants.TokenCell.Balance.font, size: Constants.TokenCell.Balance.size)
        balance.textColor = Constants.TokenCell.Balance.color
        title.font = UIFont(name: Constants.TokenCell.Title.font, size: Constants.TokenCell.Title.size)
        title.textColor = Constants.TokenCell.Title.color
        tokenImage.layer.cornerRadius = tokenImage.bounds.height/2
    }
    
    func configure(token: TableToken) {
        let balanceString = (token.token.balance ?? "...") + " \(token.token.symbol.uppercased())"
        let titleString = ("\(token.token.name)")
        
        balance.text = balanceString
        title.text = titleString
        tokenImage.layer.cornerRadius = tokenImage.bounds.height/2
        
        tokenImage.image = UIImage(named: "eth")
        if let image = UIImage(named: token.token.address) {
            tokenImage.image = image
        }
        if let url = URL(string: "https://trustwalletapp.com/images/tokens/\(token.token.address).png"), !token.token.isEther(), !token.token.isBuff() {
            loadImage(url: url)
        }
    }
    
    func loadImage(url: URL?) {
        let processor = DownsamplingImageProcessor(size: tokenImage.bounds.size)
            >> RoundCornerImageProcessor(cornerRadius: tokenImage.bounds.height/2)
        tokenImage.kf.indicatorType = .activity
        tokenImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .cacheOriginalImage
            ]) { result in
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
        balance.text = "-"
        title.text = "-"
    }
}
