//
//  BubbleMessageCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 05/11/2022.
//

import UIKit

class BubbleMessageCell: UITableViewCell {

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var emptyViewSender: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = self.bounds.size.height/4
    }
    
    func config(senderName: String, content: String) {
        senderNameLabel.text = senderName
        messageText.text = content
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
