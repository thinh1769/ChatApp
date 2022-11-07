//
//  MessageCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 09/10/2022.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var emptyViewSender: UIView!
    @IBOutlet weak var emptyViewMe: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = self.bounds.size.height/4
    }

    func config(isViewSender: Bool, isViewMe: Bool, content: String) {
        emptyViewSender.isHidden = isViewSender
        emptyViewMe.isHidden = isViewMe
        messageText.text = content
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
