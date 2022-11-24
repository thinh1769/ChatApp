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
        selectionStyle = .none 
    }
    
    func config(_ content: String) {
        notificationLabel.text = content
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }
    
}
