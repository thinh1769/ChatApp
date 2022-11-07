//
//  GroupNotificationCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 06/11/2022.
//

import UIKit

class GroupNotificationCell: UITableViewCell {

    @IBOutlet weak private var notificationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(_ content: String) {
        notificationLabel.text = content
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
