//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var conversationView: UIView!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        conversationView.layer.cornerRadius = 23
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func config(name: String, content: String) {
        userNameLabel.text = name
        lastMessageLabel.text = content
    }
    
}
