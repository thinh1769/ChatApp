//
//  GroupManagerViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 08/11/2022.
//

import UIKit

protocol ChooseNewAdminDelegate: AnyObject {
    func chooseNewAdmin(adminId: String)
}

class GroupManagerViewController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var avatarImage: UIImageView!
    
    weak var delegate: ChooseNewAdminDelegate?
    var viewModel = GroupManagerViewModel()
    
    func inject(_ lisMember: [UserInfo], _ adminId: String, _ chatId: String, _ groupName: String) {
        viewModel.listMember.accept(lisMember)
        viewModel.chatId = chatId
        viewModel.groupName = groupName
        viewModel.adminId = adminId
        if adminId == UserDefaults.userInfo?.id {
            viewModel.isAdmin = true
        } else {
            viewModel.isAdmin = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
       
    }
    
    private func setupUI() {
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
        groupNameTextField.text = viewModel.groupName
    }
    
    private func setupTableView() {
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.register(UINib(nibName: "FriendTableCell", bundle: nil), forCellReuseIdentifier: "friendTableCell")
    }

    @IBAction func onClickedBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickedLeaveBtn(_ sender: UIButton) {
        if viewModel.adminId == UserDefaults.userInfo?.id && viewModel.listMember.value.count > 1 {
            showAlert()
        } else {
            viewModel.leaveGroup()
            ///----pop to 2 previous view controller
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Cảnh báo", message: "Bạn phải chọn trường nhóm mới trước khi rời nhóm", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension GroupManagerViewController: UITableViewDelegate {
}

extension GroupManagerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listMember.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendTableCell", for: indexPath) as? FriendTableCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        if viewModel.adminId != viewModel.listMember.value[indexPath.row].id {
            cell.config(name: viewModel.listMember.value[indexPath.row].name ?? "", viewModel.isAdmin, false)
        } else {
            cell.config(name: viewModel.listMember.value[indexPath.row].name ?? "", false, true)
        }
        
        cell.actionBtnDidTappedAtIndex = {
            cell.showAction()
        }
        
        cell.chooseAdminBtnDidTappedAtIndex = { [weak self] in
            guard let self = self else { return }
            self.viewModel.chooseAdmin(index: indexPath.row)
            cell.showAction()
            self.delegate?.chooseNewAdmin(adminId: self.viewModel.listMember.value[indexPath.row].id ?? "")
            self.memberTableView.reloadData()
        }
        
        cell.removeMemberBtnDidTappedAtIndex = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeMember(index: indexPath.row)
            cell.showAction()
            self.memberTableView.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
