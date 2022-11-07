//
//  AddMemberViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 06/11/2022.
//

import UIKit
import RxCocoa
import RxSwift

class AddMemberViewController: UIViewController {

    @IBOutlet weak private var groupAvatarImage: UIImageView!
    @IBOutlet weak private var viewOfSelectedFriends: UIView!
    @IBOutlet weak private var groupNameTextField: UITextField!
    @IBOutlet weak private var searchContactTextField: UITextField!
    @IBOutlet weak private var selectedFriendsCollectionView: UICollectionView!
    @IBOutlet weak private var friendsTableView: UITableView!
    
    var viewModel = AddMemberViewModel()
    var cellSize = 0.0
    
    func inject(chatId: String, members: [UserInfo]) {
        viewModel.chatId = chatId
        viewModel.listMember.accept(members)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCollectionView()
        viewOfSelectedFriends.isHidden = true
    }
    
    private func setupUI() {
        groupAvatarImage.layer.cornerRadius = groupAvatarImage.bounds.height/2
        searchContactTextField.rx.controlEvent([.editingDidEnd]).subscribe { [weak self] _ in
            guard let self = self else { return }
            if self.searchContactTextField.text == "" {
                self.viewModel.searchFriendsList.accept([])
                self.friendsTableView.reloadData()
            }
        }onError: { _ in
        }
        .disposed(by: viewModel.bag)
        
        searchContactTextField.delegate = self
    }
    
    @IBAction func onClickedAddMemberBtn(_ sender: UIButton) {
        if let chatName = groupNameTextField.text, chatName.count > 0 && viewModel.selectedFriendsList.value.count > 0 {
            viewModel.addMember(viewModel.chatId, usersId: self.viewModel.selectedFriendsList.value)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onClickedBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.register(UINib(nibName: "FriendTableCell", bundle: nil), forCellReuseIdentifier: "friendTableCell")
    }
    
    private func setupCollectionView() {
        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self
        selectedFriendsCollectionView.register(UINib(nibName: "HomeFriendsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeFriendsCollectionViewcell")
        selectedFriendsCollectionView.backgroundColor = .clear
        cellSize = selectedFriendsCollectionView.frame.size.height
        selectedFriendsCollectionView.backgroundColor = .clear
    }

}

///---------TableView Delegate & DataSource
extension AddMemberViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !viewModel.checkSelectedFriend(viewModel.searchFriendsList.value[indexPath.row].id ?? "") {
            var list = viewModel.selectedFriendsList.value
            list.append(viewModel.searchFriendsList.value[indexPath.row].id ?? "")
            viewModel.selectedFriendsList.accept(list)
            viewOfSelectedFriends.isHidden = false
            selectedFriendsCollectionView.reloadData()
        }
    }
}

extension AddMemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchFriendsList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendTableCell", for: indexPath) as? FriendTableCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.otherUserNameLabel.text = viewModel.searchFriendsList.value[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

///------------CollectionView Delegate & DataSource
extension AddMemberViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedFriendsList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeFriendsCollectionViewcell", for: indexPath) as? HomeFriendsCollectionViewCell else { return UICollectionViewCell() }
        
        cell.avatarImage.layer.cornerRadius = cellSize/2
        cell.deleteButtonDidTappedAtIndex = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeSelectedFriend(index: indexPath.row)
            if self.viewModel.selectedFriendsList.value.count == 0 {
                self.viewOfSelectedFriends.isHidden = true
            }
            self.selectedFriendsCollectionView.reloadData()
        }
        
        return cell
    }
}

extension AddMemberViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: selectedFriendsCollectionView.bounds.size.height , height: selectedFriendsCollectionView.bounds.size.height )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

///---------------UITextFieldDelegate
extension AddMemberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nameOrPhone = searchContactTextField.text else { return false }
        viewModel.searchFriend(nameOrPhone).subscribe { listUser in
            self.viewModel.searchFriendsList.accept(listUser)
            self.friendsTableView.reloadData()
        } onError: { _ in
        }.disposed(by: viewModel.bag)
        return true
    }
}
