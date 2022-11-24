//
//  SenderMessageCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 10/11/2022.
//

import UIKit

class SenderMessageCell: UITableViewCell {
    private let messageLabel = UILabel()
    private let messageView = UIView()
    let maxMessageWidth = UIScreen.main.bounds.width * 3 / 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    private func setupUI() {
        messageView.backgroundColor = UIColor.systemBlue
        messageView.alpha = 0.1
        messageView.layer.cornerRadius = 12
        
        addSubview(messageView)
        addSubview(messageLabel)
        selectionStyle = .none
        
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
                           messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                           messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
                           messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxMessageWidth),
                           
                           messageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
                           messageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10),
                           messageView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
                           messageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func config(content: String) {
        messageLabel.text = content
    }
}
