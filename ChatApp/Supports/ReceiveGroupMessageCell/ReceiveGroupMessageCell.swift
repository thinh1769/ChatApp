//
//  ReceiveGroupMessageCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 09/11/2022.
//

import UIKit

class ReceiveGroupMessageCell: UITableViewCell {
    
    private let messageLabel = UILabel()
    private let messageView = UIView()
    private let nameLabel = UILabel()
    let maxMessageWidth = UIScreen.main.bounds.width * 3 / 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    private func setupUI() {
        messageView.backgroundColor = UIColor.systemGray6
        messageView.layer.cornerRadius = 12
        nameLabel.textColor = UIColor.systemGray2
        nameLabel.font = .systemFont(ofSize: 12)
        
        addSubview(messageView)
        addSubview(messageLabel)
        addSubview(nameLabel)
        selectionStyle = .none
        
        messageLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),
                           messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                           messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
                           messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxMessageWidth),
                           
                           messageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
                           messageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10),
                           messageView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
                           messageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10),
                           
                           nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: -5),
                           nameLabel.bottomAnchor.constraint(equalTo: messageView.topAnchor, constant: 5),
                           nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func config(name: String, content: String) {
        nameLabel.text = name
        messageLabel.text = content
    }
}
