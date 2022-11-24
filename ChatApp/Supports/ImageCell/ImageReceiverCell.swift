//
//  ImageReceiverCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 18/11/2022.
//

import UIKit

class ImageReceiverCell: UITableViewCell {
    let maxImageWidth = UIScreen.main.bounds.width * 3 / 5
    let maxImageHeight = UIScreen.main.bounds.height / 2
    var imageMessage = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    private func setupUI() {
        imageMessage.frame = CGRect(x: 0, y: 5, width: maxImageWidth, height: maxImageHeight)
        imageMessage.layer.masksToBounds = true
        imageMessage.layer.cornerRadius = 12
        imageMessage.contentMode = .scaleAspectFit
        addSubview(imageMessage)
        selectionStyle = .none
    }
    
    func configImage(image: UIImage, imageHeight: Int) {
        let ratio = image.size.width / image.size.height
        let newHeight = CGFloat(imageHeight)
        let newWidth = newHeight * ratio
        imageMessage.image = image
        imageMessage.frame = CGRect(x: 0, y: 5, width: newWidth, height: newHeight)
    }
}
