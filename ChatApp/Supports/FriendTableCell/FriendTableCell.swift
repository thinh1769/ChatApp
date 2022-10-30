//
//  FriendTableCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 29/10/2022.
//

import UIKit

class FriendTableCell: UITableViewCell {

    @IBOutlet weak var friendTableView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var otherUserNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        friendTableView.layer.cornerRadius = 23
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
