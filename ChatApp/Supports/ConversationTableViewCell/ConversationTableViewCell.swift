//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var conversationView: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        conversationView.layer.cornerRadius = 23
        avatarImage.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
