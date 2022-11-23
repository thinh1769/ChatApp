//
//  ImageReceiverGroupCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 22/11/2022.
//

import UIKit

class ImageReceiverGroupCell: UITableViewCell {
    let maxImageWidth = UIScreen.main.bounds.width * 3 / 5
    let maxImageHeight = UIScreen.main.bounds.height / 2
    var imageMessage = UIImageView()
    var nameLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    private func setupUI() {
        nameLabel.textColor = UIColor.systemGray2
        nameLabel.font = .systemFont(ofSize: 12)
        
        imageMessage.frame = CGRect(x: 0, y: 20, width: maxImageWidth, height: maxImageHeight)
        imageMessage.layer.masksToBounds = true
        imageMessage.layer.cornerRadius = 12
        imageMessage.contentMode = .scaleAspectFit
        addSubview(imageMessage)
        addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: -5),
                           nameLabel.bottomAnchor.constraint(equalTo: imageMessage.topAnchor, constant: 5),
                           nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func configImage(image: UIImage, imageHeight: Int, name: String) {
        let ratio = image.size.width / image.size.height
        let newHeight = CGFloat(imageHeight)
        let newWidth = newHeight * ratio
        imageMessage.image = image
        imageMessage.frame = CGRect(x: 0, y: 20, width: newWidth, height: newHeight)
        
        nameLabel.text = name
    }
}
