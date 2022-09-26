//
//  HomeFriendsCollectionViewCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit

class HomeFriendsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 40
    }

}
