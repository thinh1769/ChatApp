//
//  FriendTableCell.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 29/10/2022.
//

import UIKit

class FriendTableCell: UITableViewCell {

    @IBOutlet weak var keyAdminImage: UIImageView!
    @IBOutlet weak var friendTableView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var otherUserNameLabel: UILabel!
    @IBOutlet weak var removeMemberBtn: UIButton!
    @IBOutlet weak var chooseAdminBtn: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    
    var actionBtnDidTappedAtIndex: (() -> ())?
    var chooseAdminBtnDidTappedAtIndex: (() -> ())?
    var removeMemberBtnDidTappedAtIndex: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        chooseAdminBtn.isHidden = true
        removeMemberBtn.isHidden = true
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        friendTableView.layer.cornerRadius = 23
        keyAdminImage.layer.cornerRadius = keyAdminImage.bounds.height / 2
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    func config(name: String, _ isAdmin: Bool, _ isShowKeyAdmin: Bool) {
        otherUserNameLabel.text = name
        actionBtn.isHidden = !isAdmin
        keyAdminImage.isHidden = !isShowKeyAdmin
    }
    
    func showAction() {
        chooseAdminBtn.isHidden = !chooseAdminBtn.isHidden
        removeMemberBtn.isHidden = !removeMemberBtn.isHidden
    }
    
    @IBAction func onClickedActionBtn(_ sender: UIButton) {
        self.actionBtnDidTappedAtIndex?()
    }
    
    @IBAction func onClickedRemoveMemberBtn(_ sender: UIButton) {
        self.removeMemberBtnDidTappedAtIndex?()
    }
    
    @IBAction func onClickedChooseAdminBtn(_ sender: UIButton) {
        self.chooseAdminBtnDidTappedAtIndex?()
    }
}
