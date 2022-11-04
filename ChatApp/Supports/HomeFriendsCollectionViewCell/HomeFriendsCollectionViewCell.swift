//
//  HomeFriendsCollectionViewCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit

class HomeFriendsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var deleteButtonDidTappedAtIndex : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //avatarImage.layer.cornerRadius = 40
    }
    @IBAction func onClickedDeleteBtn(_ sender: UIButton) {
        self.deleteButtonDidTappedAtIndex?()
    }
    
}
